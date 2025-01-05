
# OpenAI Client for Ruby

![Gem Version](https://badge.fury.io/rb/openai-client.svg) ![License](https://img.shields.io/badge/license-MIT-brightgreen) ![Ruby](https://img.shields.io/badge/Ruby-%3E%3D%202.5-red)

## 1. Abstract
The `openai-client` is a lightweight Ruby library designed to simplify interactions with the OpenAI API, enabling developers to build agents that can handle complex conversations, utilize function calling, and maintain context through message history. With minimal setup, you can start integrating AI-powered functionalities into your Ruby applications.

Key features include:
- Easy integration with OpenAI's chat completions endpoint.
- Support for function calling to execute custom tasks.
- Message history management for context-driven responses.
- Console-based interaction for rapid prototyping.

---

## 2. Installation

To install the gem, add this line to your application's Gemfile:

```ruby
gem 'openai-client', '~> 1.0.1'
```

Or install it manually from the command line:

```bash
$ gem install openai-client
```

Ensure you have the following dependencies installed:

- `uri`
- `net-http`
- `json`
- `blackstack-core`
- `colorize`
- `simple_cloud_logging`

---

## 3. Getting Started

### 3.1. Create Your OpenAI Account and Get Your API Key

1. Visit the [OpenAI Platform](https://platform.openai.com/).
2. Sign up or log in to your account.
3. Navigate to the API section to retrieve your API key.

### 3.2. Create Your Ruby Project

```bash
$ mkdir my_openai_project
$ cd my_openai_project
$ bundle init
```

Add `openai-client` to your Gemfile:

```ruby
gem 'openai-client', '~> 1.0.1'
```

Run:

```bash
$ bundle install
```

### 3.3. Basic Usage Example

#### **Step 1: Create a Configuration File**
Create a `config.rb` file to store your API key and model:

```ruby
# config.rb
OPENAI_API_KEY = 'your_api_key_here'
MODEL = 'gpt-4'
```

#### **Step 2: Write Your Ruby Script**

Create a file called `ask_the_ai.rb`:

```ruby
require_relative '../lib/openai-client.rb'
require_relative './config.rb'

# Previous messages to maintain context
previous_messages = [
  { "role" => "user", "content" => "Your name is Thelma." }
]

# Initialize the OpenAI Client
$ai = OpenAIClient.new(
  api_key: OPENAI_API_KEY,
  model: MODEL,
  messages: previous_messages
)

# Ask a question to the AI
puts $ai.ask("What is your name?")
```

#### **Step 3: Run Your Script**

```bash
$ ruby ask_the_ai.rb
```

**Output:**

```
Thelma
```

### 3.4. Using the Console Interaction

The `OpenAIClient` also includes a built-in console for interactive communication with the assistant.

```ruby
$ai.console
```
This will launch a terminal-based interface where you can type your prompts and receive responses in real-time.

---

## 3.5. Handling Function Calls

You can extend the assistant's capabilities by enabling function calling. Define your custom functions and callbacks in your Ruby application and register them with the client.

```ruby
callbacks = {
  create_tag: lambda do |args|
    { message: "Tag '#{args['name']}' created successfully!" }
  end
}

$ai = OpenAIClient.new(
  api_key: OPENAI_API_KEY,
  model: MODEL,
  functions: [
    {
      "name" => "create_tag",
      "description" => "Create a new tag for the account",
      "parameters" => {
        "type" => "object",
        "properties" => {
          "name" => { "type" => "string" },
          "color" => { "type" => "string" }
        },
        "required" => ["name"]
      }
    }
  ],
  callbacks: callbacks
)
```

Ask the assistant to create a tag:

```ruby
puts $ai.ask("Create a new tag named 'Urgent' with a red color code for account 123.")
```

**Output:**

```
Tag 'Urgent' created successfully!
```

---

## 3.6. Error Handling

The client includes comprehensive error handling for:
- Network issues.
- API errors.
- JSON parsing issues.

```ruby
begin
  response = $ai.ask("What is the capital of France?")
  puts response
rescue => e
  puts "Error: #{e.message}"
end
```

---

## License

The gem is available as open-source under the [MIT License](https://opensource.org/licenses/MIT).