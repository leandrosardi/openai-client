require_relative '../lib/simple-openai-client.rb'
require_relative './config.rb'

$ai = OpenAIClient.new(
  api_key: OPENAI_API_KEY,
  model: MODEL,
)

puts $ai.models
