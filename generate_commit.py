import sys
import torch
from transformers import GPT2TokenizerFast, AutoModelForCausalLM

MODEL_DIR = "./distilgpt2-commit-generator"  # your trained model folder
MODEL_MAX_LENGTH = 1024  # GPT-2's default max position embeddings
MAX_NEW_TOKENS = 32      # how many tokens to generate after the prompt

def clean_git_diff(diff_text, max_lines=100):
    added_lines = []
    removed_lines = []

    # Metadata lines to skip completely
    metadata_prefixes = ('diff --git', 'index ', '--- ', '+++ ', '@@ ')

    for line in diff_text.splitlines():
        # Skip git diff metadata lines
        if line.startswith(metadata_prefixes):
            continue

        # Added lines, but not the '+++ b/...' file path lines
        if line.startswith('+') and not line.startswith('+++'):
            content = line[1:].strip()
            if content:
                added_lines.append(f"+ {content}")

        # Removed lines, but not the '--- a/...' file path lines
        elif line.startswith('-') and not line.startswith('---'):
            content = line[1:].strip()
            if content:
                removed_lines.append(f"- {content}")

    # If no additions or removals, add placeholders to simulate training data style
    if not added_lines:
        added_lines = ["+ None"]
    if not removed_lines:
        removed_lines = ["- None"]

    # Limit total lines (half additions, half removals)
    half_limit = max_lines // 2
    added_lines = added_lines[:half_limit]
    removed_lines = removed_lines[:half_limit]

    return "\n".join(added_lines + removed_lines)

def load_model():
    tokenizer = GPT2TokenizerFast.from_pretrained(MODEL_DIR)
    model = AutoModelForCausalLM.from_pretrained(MODEL_DIR)
    model.eval()
    return tokenizer, model

def generate_commit_message(diff_text, tokenizer, model):
    cleaned_diff = clean_git_diff(diff_text, max_lines=100)
    prompt = f"Commit message for the following changes:\n{cleaned_diff}\n---\n"

    inputs = tokenizer(
        prompt,
        return_tensors="pt",
        truncation=True,
        max_length=model.config.n_positions - MAX_NEW_TOKENS,
    )

    with torch.no_grad():
        outputs = model.generate(
            **inputs,
            max_new_tokens=MAX_NEW_TOKENS,
            temperature=0.7,
            top_p=0.9,
            do_sample=True,
            pad_token_id=tokenizer.eos_token_id,
            eos_token_id=tokenizer.eos_token_id,
        )

    generated_tokens = outputs[0][inputs["input_ids"].shape[1]:]
    commit_message = tokenizer.decode(generated_tokens, skip_special_tokens=True).strip()

    # Return first line only to keep output concise
    return commit_message.split("\n")[0]

if __name__ == "__main__":
    if len(sys.argv) < 2 or sys.argv[1] == "-":
        diff_text = sys.stdin.read()
    else:
        diff_path = sys.argv[1]
        with open(diff_path, "r") as f:
            diff_text = f.read()

    tokenizer, model = load_model()
    commit_msg = generate_commit_message(diff_text, tokenizer, model)
    print(commit_msg)

