import re
import sys

def transform_content(filepath):
    # Regex to capture:
    # Group 1: The '### `' part (e.g., "### `")
    # Group 2: The method name (e.g., "methodName")
    # Group 3: The parameters including parentheses (e.g., "(String arg1, int arg2)")
    # Group 4: The closing '`' at the end of the original H3 line
    # Example line: ### `methodName(String arg1, int arg2)`
    # Matched groups: (### `)(methodName)(\(String arg1, int arg2\))(`)

    # Refined regex: handles methods with empty parentheses like `method()`
    # ([a-zA-Z_][a-zA-Z0-9_]*) : method name
    # (\(\)| \([^()]*\)) : parameters; matches either () or (non-empty params without nested parens)
    # Note: The regex `(\([^)]*\))` used in the python script's original comment is fine
    # for non-empty params. The script uses `(\([^)]*\))` which is okay if all methods have params.
    # Let's make it more robust for empty params as well, as in `getCurrentUser()`.
    # The pattern `\([^)]*\)` means "an opening parenthesis, followed by zero or more characters that are not closing parenthesis, followed by a closing parenthesis".
    # This will not match `()` correctly if it's empty.
    # A better pattern for parameters: `(\(.*?\))` non-greedy match between literal parentheses.
    regex = r"^(### `)([a-zA-Z_][a-zA-Z0-9_]*)(\(.*?\))(`)$"

    new_lines = []
    try:
        with open(filepath, 'r', encoding='utf-8') as f: # Added encoding
            for line in f:
                # Process line by line, strip trailing newline for matching
                original_line_stripped = line.rstrip('\n')
                match = re.match(regex, original_line_stripped)
                if match:
                    h3_start = match.group(1) # "### `"
                    method_name = match.group(2) # "methodName"
                    params_with_parens = match.group(3) # "(params)" or "()"
                    closing_backtick = match.group(4) # "`"

                    new_header = f"{h3_start}{method_name}{closing_backtick}"
                    original_signature_line = f"`{method_name}{params_with_parens}`" # Signature line needs its own backticks

                    new_lines.append(new_header + '\n')
                    new_lines.append(original_signature_line + '\n')
                else:
                    new_lines.append(line) # Append original line (with its original newline)

        # Write the transformed content back to the file
        with open(filepath, 'w', encoding='utf-8') as f: # Added encoding
            f.writelines(new_lines)

    except FileNotFoundError:
        print(f"Error: File not found at {filepath}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"An error occurred: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python transform_script.py <filepath>", file=sys.stderr)
        sys.exit(1)
    target_file = sys.argv[1]
    transform_content(target_file)
    print(f"File {target_file} transformed successfully.")
