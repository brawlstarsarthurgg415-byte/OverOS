#!/usr/bin/env python3
"""Verify the configured repair-model API before starting the ISO build."""
import json
import os
import sys
import urllib.error
import urllib.request

def main():
    providers = []
    if os.environ.get("GROQ_API_KEY"):
        providers.append(("Groq", os.environ["GROQ_API_KEY"],
                          "https://api.groq.com/openai/v1/chat/completions",
                          os.environ.get("GROQ_MODEL", "llama-3.3-70b-versatile")))
    if os.environ.get("OPENAI_API_KEY"):
        providers.append(("OpenAI", os.environ["OPENAI_API_KEY"],
                          "https://api.openai.com/v1/chat/completions",
                          os.environ.get("OPENAI_MODEL", "gpt-4.1-mini")))
    if not providers:
        print("::error::No AI API key is configured (GROQ_API_KEY or OPENAI_API_KEY).")
        return 1

    system = (
        "You are the OverOS build-repair assistant. This is a preflight health check. "
        "You do not have direct shell access; the GitHub Actions runner executes approved "
        "commands on your behalf. Confirm whether this API session is operational and "
        "whether you can respond to a request for the runner to execute a diagnostic command. "
        'Return only JSON: {"healthy":true,"can_request_command_execution":true,'
        '"message":"short status in Brazilian Portuguese"}. Do not claim you executed a command.'
    )
    last_error = "No provider returned a valid response."
    for provider, key, endpoint, model in providers:
        payload = {
            "model": model,
            "temperature": 0,
            "response_format": {"type": "json_object"},
            "max_tokens": 180,
            "messages": [
                {"role": "system", "content": system},
                {"role": "user", "content": "Faça o teste inicial. A API está respondendo e você consegue solicitar que o runner execute fastfetch?"},
            ],
        }
        request = urllib.request.Request(
            endpoint,
            data=json.dumps(payload).encode("utf-8"),
            headers={"Authorization": "Bearer " + key, "Content-Type": "application/json", "User-Agent": "OverOS-AI-Preflight/1.0 (GitHub Actions)"},
            method="POST",
        )
        try:
            with urllib.request.urlopen(request, timeout=45) as response:
                data = json.loads(response.read().decode("utf-8"))
            answer = json.loads(data["choices"][0]["message"]["content"])
            if answer.get("healthy") is not True or answer.get("can_request_command_execution") is not True:
                raise ValueError("AI did not confirm both health checks")
            message = str(answer.get("message", "API operacional; runner autorizado a executar o diagnóstico."))
            print(f"AI_PREFLIGHT_PROVIDER={provider}")
            print(f"AI_PREFLIGHT_MODEL={model}")
            print(f"AI_STATUS: {message}")
            print("AI_PREFLIGHT_OK: API respondeu e autorizou o runner a executar o diagnóstico.")
            return 0
        except urllib.error.HTTPError as error:
            detail = error.read().decode("utf-8", errors="replace")[:500]
            last_error = f"{provider} API HTTP {error.code}: {detail}"
            print(f"::warning::{last_error}. Tentando o próximo provedor disponível.")
        except Exception as error:
            last_error = f"{provider} preflight failed: {type(error).__name__}: {error}"
            print(f"::warning::{last_error}. Tentando o próximo provedor disponível.")
    print(f"::error::Nenhum provedor de IA passou no teste: {last_error}")
    return 1

if __name__ == "__main__":
    sys.exit(main())
