-- Thanks to @TiagoDanin for writing the original plugin.

if not key.google_api_key then
	print('Missing config value: google_api_key.')
	print('youtube.lua will not be enabled.')
	return
end
local command = 'youtube <$query*>'
local doc = [[```
/youtube <$query*>
$doc_youtube*
$alias*: /yt
```]]

local url = 'https://www.googleapis.com/youtube/v3/search?key=' .. key.google_api_key .. '&type=video&part=snippet&maxResults=4&q='
local action = function(msg)

	local input = msg.text:input()
	if not input then
		if msg.reply_to_message and msg.reply_to_message.text then
			input = msg.reply_to_message.text
		else
			sendMessage(msg.chat.id, sendLang(doc, lang), true, msg.message_id, true)
			return
		end
	end
	local jstr, res = HTTPS.request(url.. URL.escape(input))
	if res ~= 200 then
		sendReply(msg, config.errors.connection)
		return
	end

	local jdat = JSON.decode(jstr)
	if jdat.pageInfo.totalResults == 0 then
		sendReply(msg, config.errors.results)
		return
	end

	local i = math.random(jdat.pageInfo.resultsPerPage)
	local output = '[​](https://www.youtube.com/watch?v=' .. jdat.items[i].id.videoId .. ')'

	sendMessage(msg.chat.id, output, false, nil, true)

end

return {
	command = command,
	doc = doc,
	action = action,
	triggers = {
		'^/youtube[@'..bot.username..']*',
		'^/yt[@'..bot.username..']*$',
		'^/yt[@'..bot.username..']* '
	}
}
