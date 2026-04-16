require_relative 'auth'

if sympla_token
  puts 'OK'
else
  puts 'SETUP_NEEDED'
  $stderr.puts ''
  $stderr.puts 'Token não encontrado. Configure de uma das formas:'
  $stderr.puts "  1. export SYMPLA_TOKEN=seu_token"
  $stderr.puts "  2. echo '{\"token\":\"seu_token\"}' > ~/.sympla/config.json"
  exit 1
end
