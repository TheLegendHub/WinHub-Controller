from transformers import AutoModelForCausalLM, AutoTokenizer
import torch

model = AutoModelForCausalLM.from_pretrained(
    "deepseek-ai/deepseek-coder-6.7b-base",
    device_map="auto",
    trust_remote_code=True,
    cache_dir="/home/it3/.cache/huggingface",
    torch_dtype=torch.float16,       # 👈 Reduced memory usage
    low_cpu_mem_usage=True
)

tokenizer = AutoTokenizer.from_pretrained(
    "deepseek-ai/deepseek-coder-6.7b-base",
    trust_remote_code=True,
    cache_dir="/home/it3/.cache/huggingface"
)
