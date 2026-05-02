---
name: Vitest Testing Guidelines
description: Rules and conventions for all Vitest test code — unit tests, integration tests, test structure, expectations, and mocking
applyTo: "**/*.{test,spec}.{ts,tsx,mts,cts,js,mjs,cjs}"
---

# Vitest Testing Guidelines

## General Testing Guidelines

- Use `vitest` for unit and integration testing.
- Prefer `describe`/`it` (BDD style: "describe [subject], it [should do behavior]") over `suite`/`test` — they are aliases, but pick one for consistency across the codebase.
- Follow AAA (Arrange-Act-Assert) pattern for test structure.
- Use mocks and spies for isolating dependencies.
- Aim for high code coverage but prioritize meaningful tests over coverage percentage.
- Use type assertions in tests to ensure type safety.
- Prefer testing public APIs over internal implementation details.
- Organize tests alongside the code they test. Name test files with `.test.ts` suffix for clarity.
- For utility functions and classes, write tests that cover various input scenarios, edge cases, and error handling.
- For modules with side effects (e.g., file I/O, network requests), write integration tests that verify the overall behavior and interactions.
- For complex business logic, write unit tests that isolate specific functions or methods to ensure correctness. When writing integration tests for complex business logic, use real dependencies where feasible to validate interactions.
- When temporary files or directories are needed for tests, use the Node.js `mkdtemp` function to create unique temporary directories safely.
- Ensure tests are deterministic and can run in isolation without relying on external state.
- Ensure tests are independent and can run in any order (eg. clear mocks between tests).
- When relevant, use external fixtures from a colocated `__fixtures__` directory.

## Expectation Guidelines

- Always use specific matchers for assertions to improve test clarity and accuracy.

  ```typescript
  // ✅ CORRECT
  expect(value).toBe(42);
  expect(array).toHaveLength(3);
  expect(object).toHaveProperty('key', 'value');
  // ❌ WRONG - vague assertion
  expect(value).toBeDefined();
  // ❌ WRONG - less specific
  expect(array.length).toBe(3);
  ```

- When testing error throwing, always assert the error class when the error is semantically distinguishable (i.e., it exists to be caught and differentiated from other errors). Never assert on the error message — messages may change without being a breaking change.

  ```typescript
  // ✅ CORRECT — specific class, error is meaningfully typed
  expect(() => someFunction()).toThrowError(NotFoundError);
  // ✅ CORRECT — acceptable when the error type is genuinely generic / not catchable by callers
  expect(() => someFunction()).toThrowError();
  // ❌ WRONG — never assert on message strings; they may change
  expect(() => someFunction()).toThrowError('Specific error message');
  // ❌ WRONG — use .toThrowError() not .toThrow()
  expect(() => someFunction()).toThrow();
  ```

- When testing concurrent or racing async behaviors, it is acceptable to use `.then()` to fire a promise without immediately awaiting it, in order to observe side effects while another operation is in progress. This is one of the few legitimate uses of `.then()` outside of event chaining.

  ```typescript
  // ✅ CORRECT — need to start the send without blocking, to observe concurrent behavior
  let received: number | undefined;
  const recv = ch.receive().then((v) => (received = v));
  await delay(10); // ensure receive is waiting
  await ch.send(42);
  await recv;
  expect(received).toBe(42);
  ```

- Never use `expect` in callbacks, conditions, or event handlers — use flags or promises to signal test completion.

  ```typescript
  // ✅ CORRECT
  let callbackCalled = false;
  someAsyncFunction(() => { callbackCalled = true; });
  await waitFor(() => expect(callbackCalled).toBe(true));

  // ❌ WRONG — expect inside a callback, condition, or event handler
  someAsyncFunction(() => { expect(true).toBe(true); });
  ```

- Never use `toHaveBeenCalled` without verifying the arguments and the call counts; prefer using `toHaveBeenCalledWith` and `toHaveBeenCalledTimes` for more precise assertions.

  ```typescript
  // ✅ CORRECT
  expect(mockFunction).toHaveBeenCalledTimes(2);
  expect(mockFunction).toHaveBeenCalledWith(expectedArg1, expectedArg2);

  // ❌ WRONG - vague call check
  expect(mockFunction).toHaveBeenCalled();
  ```

- When testing event emitters or callbacks, always verify call counts and arguments — use `vi.fn()` for precise assertions:

  ```typescript
  // ✅ CORRECT
  const onError = vi.fn();
  server.on('error', onError);
  expect(onError).toHaveBeenCalledTimes(1);
  expect(onError).toHaveBeenCalledWith(expect.any(SpecificError));

  // ❌ WRONG — no call count verified
  let lastErrorReceived: Error | null = null;
  server.on('error', (error) => { lastErrorReceived = error; });
  expect(lastErrorReceived).toBeInstanceOf(SpecificError);
  ```

- Make extensive use of `vi.fn` instead of manual mock implementations for better readability and maintainability.

  ```typescript
  // ✅ CORRECT
  const mockFunction = vi.fn();
  someFunctionThatCallsMock(mockFunction);
  expect(mockFunction).toHaveBeenCalledWith(expectedArg);

  // ❌ WRONG — manual mock implementation
  let wasCalled = false;
  let receivedArg: unknown = null;
  const mockFunction = (arg: unknown) => { wasCalled = true; receivedArg = arg; };
  someFunctionThatCallsMock(mockFunction);
  expect(wasCalled).toBe(true);
  expect(receivedArg).toBe(expectedArg);
  ```

## Mocking Guidelines

- Always mock external dependencies to isolate the unit under test.
- Do not overuse mocks in integration tests; prefer real implementations where feasible (e.g., for database access, network requests).
- Use the `vitest-mock-extended` library for advanced mocking capabilities, particularly for complex interfaces and classes.

  ```typescript
  // ✅ CORRECT
  import { mock } from 'vitest-mock-extended';
  import { SomeComplexInterface } from '../path/to/interface';
  const mockComplex = mock<SomeComplexInterface>();

  // ❌ WRONG - manual mock can be error-prone and verbose
  const mockComplex: SomeComplexInterface = {
    methodA: vi.fn(),
    methodB: vi.fn(),
    // ...other methods and properties
  };

  // ❌ WRONG - partial mock with "as" can lead to runtime errors
  const mockComplex = {
    methodA: vi.fn(),
  } as SomeComplexInterface;
  ```

- When using `vi.mock()`, always use `importActual` to retain unmocked functionality when needed. Also always use the `import()` syntax to ensure proper module resolution and type safety.

  ```typescript
  // ✅ CORRECT
  vi.mock(import('../some-module'), async (importActual) => {
    const actual = await importActual();
    return {
      ...actual,
      specificFunction: vi.fn(),
    };
  });

  // ❌ WRONG - doesn't preserve actual exports
  vi.mock('../some-module', () => ({
    specificFunction: vi.fn(),
  }));
  ```

## Timer and Time-Based Testing

- Use `vi.useFakeTimers()` to control time in tests that depend on `setTimeout`, `setInterval`, `Date.now()`, or `performance.now()`. Always restore real timers after the test:

  ```typescript
  // ✅ CORRECT — fake timers with cleanup
  beforeEach(() => {
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('should call callback after delay', () => {
    const callback = vi.fn();
    setTimeout(callback, 1000);
    vi.advanceTimersByTime(1000);
    expect(callback).toHaveBeenCalledTimes(1);
  });
  ```

- Use `vi.advanceTimersByTime(ms)` to advance all pending timers by a fixed duration without waiting.
- Use `vi.runAllTimers()` to flush all pending timers immediately. Use `vi.runAllTimersAsync()` when timers schedule async work.
- Use `vi.setSystemTime(date)` to fix `Date.now()` and `new Date()` to a known instant — useful for testing date formatting, expiry logic, and timestamps:

  ```typescript
  vi.useFakeTimers();
  vi.setSystemTime(new Date('2026-01-01T00:00:00Z'));
  expect(new Date().getFullYear()).toBe(2026);
  ```

- Never use `setTimeout` with `await new Promise(resolve => setTimeout(resolve, ms))` in tests to wait for async side effects — use fake timers combined with `vi.advanceTimersByTime` instead.

## Type-Level Testing

- Use `.test-d.ts` files for type-level tests. These files validate TypeScript type behavior without any runtime assertions.
- Enable type checking in your vitest project config: `typecheck: { enabled: true }` in `defineProject`.
- Use `assertType<T>(value)` from vitest to assert that a value has an exact type at compile time.
- Use `expectTypeOf(value).toEqualTypeOf<T>()` for more flexible type assertions (see <https://vitest.dev/api/expect-typeof.html>).
- Prefer `assertType` for straightforward exact-type validation; prefer `expectTypeOf` for expressive checks (e.g., `.toBeAssignableTo`, `.toHaveProperty`).

  ```typescript
  // ✅ CORRECT — .test-d.ts file
  import { assertType, suite, test } from 'vitest';
  import type { NonNullish } from './non-nullish.js';

  suite('NonNullish', () => {
    test('should exclude null and undefined', () => {
      type A = string | null | undefined;
      type B = NonNullish<A>;
      const a: B = 'hello';
      assertType<string>(a);
    });
  });
  ```
