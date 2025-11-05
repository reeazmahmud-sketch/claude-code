---
allowed-tools: Bash(find:*), Bash(grep:*), Bash(sed:*), Bash(wc:*)
description: List all available custom agents that can be used for specialized tasks
---

# List Available Agents

Show all custom agents available in this repository. These are specialized agents that can be invoked to perform specific tasks like code review, architecture design, test analysis, and more.

## Instructions

Execute the following bash commands to find and display all available agents:

1. **Find all agent files**
   ```bash
   find plugins -type f -path "*/agents/*.md" | sort
   ```

2. **For each plugin, display agents with their metadata**
   - Extract name from frontmatter (`name:` field) or filename
   - Extract description from frontmatter (`description:` field)
   - Extract model from frontmatter (`model:` field)
   - Show file location for reference

3. **Group by plugin and format output**
   - Group agents by their plugin directory
   - Show plugin name and path
   - List each agent with:
     - Number (sequential)
     - Agent name
     - Description (truncated to ~200 chars if too long)
     - Model (if specified)
     - File location
   - Include summary count at end

## Implementation Approach

Here's a bash script to accomplish this:

```bash
#!/bin/bash

echo "Available Custom Agents"
echo "======================"
echo ""

# Find all agent directories
agent_dirs=$(find plugins -type d -name "agents" | sort)

total_agents=0
plugin_count=0

for agent_dir in $agent_dirs; do
    # Get plugin name from path
    plugin_name=$(echo "$agent_dir" | sed 's|plugins/\([^/]*\)/agents|\1|')
    
    # Find agent files
    agent_files=$(find "$agent_dir" -type f -name "*.md" | sort)
    
    # Check if there are any agent files
    if [ -n "$agent_files" ]; then
        plugin_count=$((plugin_count + 1))
        
        echo "Plugin: $plugin_name ($agent_dir)"
        echo "----------------------------------------"
        
        # Process each agent file
        while IFS= read -r agent_file; do
            [ -z "$agent_file" ] && continue
            total_agents=$((total_agents + 1))
            
            # Extract metadata from frontmatter
            name=$(grep "^name:" "$agent_file" | head -1 | sed -n 's/^name: *//p')
            description=$(grep "^description:" "$agent_file" | head -1 | sed -n 's/^description: *//p')
            model=$(grep "^model:" "$agent_file" | head -1 | sed -n 's/^model: *//p')
            
            # If name is not in frontmatter, use filename
            if [ -z "$name" ]; then
                name=$(basename "$agent_file" .md)
            fi
            
            echo "  $total_agents. $name"
            if [ -n "$description" ]; then
                # Truncate long descriptions to first 200 characters (portable way)
                desc_len=${#description}
                if [ "$desc_len" -gt 200 ]; then
                    description=$(echo "$description" | cut -c1-200)
                    description="${description}..."
                fi
                echo "     Description: $description"
            fi
            if [ -n "$model" ]; then
                echo "     Model: $model"
            fi
            echo "     Location: $agent_file"
            echo ""
        done <<< "$agent_files"
        echo ""
    fi
done

echo "Summary"
echo "======="
echo "Total: $total_agents agents available across $plugin_count plugins"
```

## How to Use Agents

Once you've identified an agent you want to use, you can invoke it by:
1. Asking Claude to use the specific agent by name
2. Triggering it naturally by asking questions that match the agent's focus area
3. Using the agent in a command workflow (if the command supports agent invocation)

## Notes

- Agents are specialized AI assistants with specific expertise areas
- Each agent has its own model, tools, and instructions
- Agents can be invoked automatically based on context or explicitly by name
- Review the agent's location file for detailed instructions on when and how to use it
