# find_links
Windows tool using PowerShell to find all links in filesystem

### Usage: 
```
find_links -p <path> [-r] [-x] [-t] [-f <filter>]
-path | -p: Path to search (required)
-recurse | -r: recursive search
-exec | -x: Open tsv using explorer
-tsv | -t: Output in tsv format (tab separated)
-filter | -f: Filter the target using optional wildcards Eg: *foo*
```

### Installation:
Just download files and put in an 'app' directory of your choosing (both cmd and ps1 are requried)
Add the installed directory to your user's PATH environment varaible
