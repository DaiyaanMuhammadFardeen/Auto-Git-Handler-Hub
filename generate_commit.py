import sys
import os
import subprocess
import torch
from transformers import GPT2TokenizerFast, AutoModelForCausalLM

MODEL_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "distilgpt2-commit-generator"))
MODEL_MAX_LENGTH = 1024
MAX_NEW_TOKENS = 32

def clean_git_diff(diff_text, max_lines=100):
    added_lines, removed_lines = [], []
    metadata_prefixes = ('diff --git', 'index ', '--- ', '+++ ', '@@ ')
    for line in diff_text.splitlines():
        if line.startswith(metadata_prefixes):
            continue
        if line.startswith('+') and not line.startswith('+++'):
            content = line[1:].strip()
            if content:
                added_lines.append(f"+ {content}")
        elif line.startswith('-') and not line.startswith('---'):
            content = line[1:].strip()
            if content:
                removed_lines.append(f"- {content}")

    if not added_lines:
        added_lines = ["+ None"]
    if not removed_lines:
        removed_lines = ["- None"]

    half_limit = max_lines // 2
    return "\n".join(added_lines[:half_limit] + removed_lines[:half_limit])

def load_model():
    print("Loading GPT2 model...", file=sys.stderr)
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
    return commit_message.split("\n")[0]

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("[ERROR] No files passed", file=sys.stderr)
        sys.exit(1)

    files = sys.argv[1:]
    tokenizer, model = load_model()

    for f in files:
        # Get diff for file
        result = subprocess.run(["git", "diff", "--cached", f], capture_output=True, text=True)
        diff_text = result.stdout.strip()

        if not diff_text:
            print(f"[SKIP] {f} (no staged changes)", file=sys.stderr)
            continue

        commit_msg = generate_commit_message(diff_text, tokenizer, model)

        print(f"[COMMIT] {f} → {commit_msg}", file=sys.stderr)

        # Commit just that file
        subprocess.run(["git", "commit", f, "-m", f"{commit_msg} -GPT2"])
