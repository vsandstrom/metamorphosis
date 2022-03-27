# metamorphosis

In code, assign the path/to/your/audio/files/folder to the "path"-variable.

If done correctly, the installation can be run on a Raspberry Pi accessed through ssh by running 
```supercollider
sclang Installation.scd
```

Since the idea is to run this script on a Raspberry Pi headless on startup, there is no reason to implement a setting of samples-path as CLI, it should be hardcoded.
