# Renovate configuration presets

<https://docs.renovatebot.com/key-concepts/presets/>

## Additional packageRules

### Disable auto merge on matching packages

```json
  {
   "description": "Disable auto merge",
   "automerge": false,
   "matchPackageNames": []
  }
```

### Disable all updates on matching packages

```json
  {
   "description": "Disable updates",
   "enabled": false,
   "matchPackageNames": []
  }
```
