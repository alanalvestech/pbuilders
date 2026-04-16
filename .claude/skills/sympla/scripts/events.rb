require_relative 'auth'

# Uso: events.rb [--page N] [--size N]

params = {}
params[:page] = ARGV[ARGV.index('--page') + 1].to_i if ARGV.include?('--page')
params[:size] = ARGV[ARGV.index('--size') + 1].to_i if ARGV.include?('--size')

data   = sympla_request(:get, '/events', params: params)
events = data['data'] || []

if events.empty?
  puts '(nenhum evento encontrado)'
  exit 0
end

events.each do |e|
  date = e['start_date'] || ''
  puts "#{e['id'].to_s.ljust(12)} #{e['name'].ljust(50)} #{date}"
end

puts "\n#{events.size} evento(s)"
