require_relative 'auth'

# Uso: checkin.rb EVENT_ID --participant PARTICIPANT_ID
#      checkin.rb EVENT_ID --ticket TICKET_NUMBER

event_id = ARGV[0] || ENV['SYMPLA_EVENT_ID']

unless event_id
  $stderr.puts "Uso: checkin.rb EVENT_ID --participant PARTICIPANT_ID"
  $stderr.puts "     checkin.rb EVENT_ID --ticket TICKET_NUMBER"
  exit 1
end

if ARGV.include?('--participant')
  participant_id = ARGV[ARGV.index('--participant') + 1]
  path = "/events/#{event_id}/participants/#{participant_id}/checkin"
elsif ARGV.include?('--ticket')
  ticket = ARGV[ARGV.index('--ticket') + 1]
  path = "/events/#{event_id}/participants/ticketNumber/#{ticket}/checkin"
else
  $stderr.puts "Informe --participant PARTICIPANT_ID ou --ticket TICKET_NUMBER"
  exit 1
end

data = sympla_request(:post, path)

puts "Check-in realizado."
puts "Participante: #{data.dig('data', 'first_name')} #{data.dig('data', 'last_name')}"
puts "Ticket:       #{data.dig('data', 'ticket_number')}"
