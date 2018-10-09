require 'net/https'
require 'uri'
require 'json'
require 'slack/incoming/webhooks'

def get_vulners(size)
	#1.Vulners APIを取得
	vulners_datas = Hash.new{ |h,k| h[k] = {}}

	uri = URI.parse("https://vulners.com/api/v3/search/lucene" + "/?query=type%3Acisco" + "&sort=order%3Apublished" + "&size=#{size}")
	json = Net::HTTP.get(uri)
	result = JSON.parse(json)

	#返ってきた値をvulners_datasに格納
	size.times do |i|
		vulners_datas[i]['id'] = result['data']['search'][i]['_source']['id']
		vulners_datas[i]['title'] = result['data']['search'][i]['_source']['title']
		vulners_datas[i]['href'] = result['data']['search'][i]['_source']['href']
		vulners_datas[i]['published'] = result['data']['search'][i]['_source']['published']
		vulners_datas[i]['modified'] = result['data']['search'][i]['_source']['modified']
		vulners_datas[i]['description'] = result['data']['search'][i]['_source']['description']
		vulners_datas[i]['cvss_score'] = result['data']['search'][i]['_source']['cvss']['score']
		print vulners_datas[i]['id'] + "\t\t" +vulners_datas[i]['modified'] + "\n"
	end
	# puts "\n#{size}件取得成功\n"

	#2.Slackの着信Webフック
	slack = Slack::Incoming::Webhooks.new("ここにトークンを記述")
	slack.post("新たな脆弱性をキャッチしました。")
	size.times do |i|
		slack.post "#{i + 1}件目".to_json
		slack.post vulners_datas[i]['modified'].to_json
		slack.post vulners_datas[i]['id'].to_json
		slack.post vulners_datas[i]['href'].to_json
		slack.post vulners_datas[i]['cvss_score'].to_json
		slack.post (vulners_datas[i]['description']).to_json
	end
	#TODO Slackに送信できたかどうかを確認してターミナルに出力
end

print "件数："
input = gets.chomp.to_i
get_vulners(input)