require_relative 'auth'

# Uso: orders.rb EVENT_ID [--page N] [--size N]

event_id = ARGV[0] || ENV['SYMPLA_EVENT_ID']

unless event_id
  $stderr.puts "Uso: orders.rb EVENT_ID [--page N] [--size N]"
  exit 1
end

params = {}
params[:page] = ARGV[ARGV.index('--page') + 1].to_i if ARGV.include?('--page')
params[:size] = ARGV[ARGV.index('--size') + 1].to_i if ARGV.include?('--size')

data   = sympla_request(:get, "/events/#{event_id}/orders", params: params)
orders = data['data'] || []

if orders.empty?
  puts '(nenhum pedido encontrado)'
  exit 0
end

orders.each do |o|
  name  = "#{o['first_name']} #{o['last_name']}".ljust(35)
  email = o['email'].to_s.ljust(35)
  qtd   = o['qtd_total'].to_s.ljust(4)
  puts "#{o['order_id'].to_s.ljust(16)} #{name} #{email} qtd=#{qtd}"
end

puts "\n#{orders.size} pedido(s) — página #{params[:page] || 1}"
