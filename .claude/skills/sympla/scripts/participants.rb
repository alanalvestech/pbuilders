require_relative 'auth'

# Uso: participants.rb EVENT_ID [--page N] [--size N]

event_id = ARGV[0] || ENV['SYMPLA_EVENT_ID']

unless event_id
  $stderr.puts "Uso: participants.rb EVENT_ID [--page N] [--size N]"
  exit 1
end

params = {}
params[:page] = ARGV[ARGV.index('--page') + 1].to_i if ARGV.include?('--page')
params[:size] = ARGV[ARGV.index('--size') + 1].to_i if ARGV.include?('--size')

data         = sympla_request(:get, "/events/#{event_id}/participants", params: params)
participants = data['data'] || []

if participants.empty?
  puts '(nenhum participante encontrado)'
  exit 0
end

participants.each do |p|
  checked = p['checked_in'] ? '✓' : ' '
  ticket  = p['ticket_number'].to_s.ljust(16)
  name    = "#{p['first_name']} #{p['last_name']}".ljust(35)
  email   = p['email'].to_s.ljust(35)
  puts "[#{checked}] #{ticket} #{name} #{email}"
end

puts "\n#{participants.size} participante(s) — página #{params[:page] || 1}"
