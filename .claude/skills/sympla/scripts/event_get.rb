require_relative 'auth'

# Uso: event_get.rb EVENT_ID

event_id = ARGV[0] || ENV['SYMPLA_EVENT_ID']

unless event_id
  $stderr.puts "Uso: event_get.rb EVENT_ID"
  exit 1
end

data = sympla_request(:get, "/events/#{event_id}")
e    = data['data'] || data

puts "ID:        #{e['id']}"
puts "Nome:      #{e['name']}"
puts "Início:    #{e['start_date']}"
puts "Fim:       #{e['end_date']}"
puts "Local:     #{e.dig('address', 'name')} — #{e.dig('address', 'address')}, #{e.dig('address', 'city')}"
puts "Ingressos: #{e['total_tickets_sold']} vendidos / #{e['total_tickets']} total"
puts "URL:       #{e['url']}"
