# Tech Context - enclavr-root

## Technologies Used
- **gh CLI**: GitHub operations
- **curl**: API requests
- **jq**: JSON processing
- **git submodules**: Multi-repo management

## CLI Commands
```bash
# Check all repos for issues
gh issue list -R enclavr/<repo> --state open

# Update submodules
git submodule update --remote

# Run autonomous agent
./script/main.sh
```
