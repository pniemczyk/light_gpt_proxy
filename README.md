# LightGptProxy

LightGptProxy is a simple, lightweight proxy server that routes requests to different providers using customizable templates. It supports encrypted configurations and easy setup, making it a flexible tool for managing proxy requests.

## Installation

Add this line to your application's Gemfile:

```bash
gem 'light_gpt_proxy'
```

## Usage

### Starting the Proxy Server

To start the LightGPT Proxy server:

light_gpt_proxy start [options]

Options:
- -p, --port PORT - Set the port for the LightGPT Proxy server. You can also set the port using the environment variable LIGHT_GPT_PROXY_PORT.
- -d, --directory DIR - Specify the directory where the configuration file will be generated.
- -c, --current - Use the current directory where the configuration file will be generated.
- -v, --verbose - Enable verbose logging.
- -s, --specific x,y,z - Specify providers (comma or space-separated).
- -e, --encrypt PASSWORD - Encrypt configuration file using a password or environment variable LIGHT_GPT_PROXY_PASSWORD.
- -f, --force - Force start the server by terminating any existing process and starting a new one.

Example:

light_gpt_proxy start -p 3000 --verbose

### Stopping the Proxy Server

To stop the running LightGPT Proxy server:

light_gpt_proxy stop

This command will stop the server if it's running.

### Generating a Configuration File

To generate a new configuration file:

light_gpt_proxy gen [options]

Options:
- -d, --directory DIR - Specify the directory where the configuration file will be generated.
- -c, --current - Use the current directory where the configuration file will be generated.
- -s, --specific x,y,z - Specify providers (comma or space-separated).
- -p, --port PORT - Set the port for the LightGPT Proxy server.
- -e, --encrypted PASSWORD - Encrypt the configuration file with a password.

Example:

light_gpt_proxy gen --current -s Provider1,Provider2

### Encrypting the Configuration File

To encrypt an existing configuration file:

light_gpt_proxy encrypt [options]

Options:
- -e, --encrypt PASSWORD - Encrypt the configuration file using a password, or by using the environment variable LIGHT_GPT_PROXY_PASSWORD.

Example:

light_gpt_proxy encrypt -e my_secure_password

### Decrypting the Configuration File

To decrypt an encrypted configuration file:

light_gpt_proxy decrypt [options]

Options:
- -e, --encrypted PASSWORD - Decrypt the configuration file using a password, or by using the environment variable LIGHT_GPT_PROXY_PASSWORD.

Example:

light_gpt_proxy decrypt -e my_secure_password

### Viewing Configuration Information

To display the current configuration settings:

light_gpt_proxy --info

This will show the current port, providers, logging level, and configuration file location.

### Help

For help and available commands:

light_gpt_proxy --help

This will display all available commands and options.

## OpenAI

https://platform.openai.com/docs/api-reference/introduction

## Ollama

https://ollama.com/

```shell
ollama run llama3.2
```

## Next features

### Profiles

By profile all default settings will be overridden. For example

```yaml
profiles:
  completions:
    trans_pl_en:
      model: "gpt-4-turbo"
      messages:
        - role: system
          content: 'You are a translator, everything you receive next should be translated into Polish or English.\nIf the given text is in English, translate it into Polish.\nIf the text is in Polish, translate it into English.\nTry to translate in a way that sounds natural to a native speaker of that language.\nOnly return the translation of the text; you don’t need to translate the code.'
    programmer_ruby:
      model: "gpt-4o-mini"
      messages:
        - role: system
          content: "You are an AI programming assistant.\nFollow the user's requirements carefully & to the letter.\nYour expertise is strictly limited to software development topics.\nKeep your answers short and impersonal.\n\nYou can answer general programming questions and perform the following tasks:\n* Explain shortly how the selected code works\n* Generate unit tests for the selected code\n* Propose a fix for the problems in the selected code\n* Scaffold code for a new workspace\n* Find relevant code to your query\n* Propose a plan to implement a feature/architecture\nFirst think step-by-step - describe your plan for what to build in pseudocode, written out in great detail.\nThen output the code in a single code block.\nMinimize any other prose.\nUse Markdown formatting in your answers.\nMake sure to include the programming language name at the start of the Markdown code blocks.\nAvoid wrapping the whole response in triple backticks.\nYou can only give one reply for each conversation turn.\nFocus mainly on Ruby, Ruby on Rails, JavaScript, TypeScript, HTML, CSS, SCSS, SQL."
```

Now you can run the command with the profile

```shell
curl -i -X POST \
   -H "Content-Type:application/json" \
   -d \
'{
  "messages": [
    {
      "role": "user", 
      "content": "Gdy pada deszcz nie wiem co ze sobą zrobić :D"
    }
  ],
  "max_tokens": 50,
  "temperature": 0.7
}' \
 'http://localhost:3030/open_ai/completions?profile=trans_pl_en'
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
