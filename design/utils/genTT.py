import csv
import itertools
import sys
import re

if len(sys.argv) != 2:
    print("usage: python tt.py <input_list_file>")
    sys.exit(1)

inputList_File = sys.argv[1]

def parse_spec_file(filename):
    inputs = {}
    outputs = []
    mode = None
    
    with open(filename, "r") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            
            # Handle section markers with or without colons
            if line == ".i" or line == ".i:":
                mode = "inputs"
                continue
            elif line == ".o" or line == ".o:":
                mode = "outputs"
                continue
            
            if mode == "inputs":
                # Match: Name {val1,val2,val3} or Name description {val1,val2,val3}
                # Changed to capture any non-whitespace as variable name (including h/m)
                match = re.match(r"(\S+)(?:\s+[^{]*?)?\s*\{([^}]+)\}", line)
                if match:
                    name = match.group(1)
                    values = [v.strip() for v in match.group(2).split(",")]
                    inputs[name] = values
            elif mode == "outputs":
                outputs.append(line)
    
    return inputs, outputs

def generate_truth_table_csv(inputs_dict, outputs, filename="truth_table.csv"):
    input_names = list(inputs_dict.keys())
    input_values = [inputs_dict[name] for name in input_names]
    
    with open(filename, "w", newline="") as f:
        writer = csv.writer(f)
        # Header: inputs + outputs
        writer.writerow(input_names + outputs)
        
        # Generate all combinations
        for combination in itertools.product(*input_values):
            row = list(combination) + [""] * len(outputs)
            writer.writerow(row)

if __name__ == "__main__":
    inputs_dict, outputs = parse_spec_file(inputList_File)
    if not inputs_dict:
        print("No inputs found.")
        sys.exit(1)
    
    print(f"Found {len(inputs_dict)} inputs: {list(inputs_dict.keys())}")
    print(f"Found {len(outputs)} outputs: {outputs}")
    generate_truth_table_csv(inputs_dict, outputs)
    print(f"Truth table generated successfully!")
