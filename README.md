Installation
```
git clone
git submodule init
git submodule update --remote

pip install scons
```

Update repo
```
git pull --recurse-submodules
```

Build editor

```
cd godot
scons

./bin/<editor_binary>
```

Build tests

```
cd godot
scons dev_build=yes tests=yes
./bin/<editor_binary> --test --source-file=*test_unknoter* --success
```

