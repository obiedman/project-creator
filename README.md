# ProjectCreator

Be sure to create a config file somewhere on your system. The script defaults to searching for it in ```~/.project_creator_config.yml```. For ease of use I suggest 
putting it there, but if you decide you'd like it somewhere else you can simply change line 37 in ProjectCreator:

```ruby
options.config = Pathname(ENV['HOME']) + ".project_creator_config.yml"
```

You can check out a sample config file [HERE](sample_config.yml). Just match it to however you prefer your project's structure and you're ready to go. Note that the config file should reflect the structure you want INSIDE your project's folder, excluding the root level folder name. That top level directory will be 
created when the script is run, and everything in the config while will be created inside that folder.

Once the script is in your path, the usage is simple: ```ProjectCreator [project name]```

Use ```-h``` or ```--help``` flag for more info. 