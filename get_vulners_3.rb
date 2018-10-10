def get_vulners(size)
    #1.Vulners APIを取得
    uri = URI.parse("https://vulners.com/api/v3/search/lucene" + "/?query=type%3Acisco" + "&sort=order%3Apublished" + "&size=#{size}")
    json = Net::HTTP.get(uri)
    result = JSON.parse(json)

    #2.Slackの着信Webフック
    slack = Slack::Incoming::Webhooks.new("https://hooks.slack.com/services/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")
    slack.post("新たな脆弱性をキャッチしました。")
    result["data"]["search"].each_with_index do |x,i|
        data = x["_source"]
        slack.post "#{i + 1}件目".to_json
        slack.post data["modified"].to_json
        slack.post data["id"].to_json
        slack.post data["href"].to_json
        slack.post data["cvss"]["score"].to_json
        slack.post data["description"].to_json
        puts "#{data["id"]}\t\t#{data["modified"]}"
    end
    #TODO Slackに送信できたかどうかを確認してターミナルに出力
end

print "件数："
input = gets.chomp.to_i
get_vulners(input)
