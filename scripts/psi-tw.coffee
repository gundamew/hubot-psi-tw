module.exports = (robot) ->
    robot.hear /psi\s+(.*)/i, (msg) ->
        siteName = msg.match[1]

        msg.http('http://opendata2.epa.gov.tw/AQX.json')
        .header('Accept', 'application/json')
        .get() (err, res, body) ->
            result = JSON.parse body

            response = ''
            for siteData in result
                if siteName is siteData.SiteName
                    response += '「' + siteData.SiteName + '」測站資訊'
                    response += "\n"

                    response += '即時空氣污染指標（PSI）：'
                    if siteData.PSI isnt '' then response += siteData.PSI + ' ' + siteData.Status else response += '設備維護'
                    response += "\n"

                    response += '懸浮微粒（PM10）濃度：'
                    if siteData.PM10 isnt '' then response += siteData.PM10 + ' μg/m3' else response += '設備維護'
                    response += "\n"

                    response += '臭氧（O3）濃度：'
                    if siteData.O3 isnt '' then response += siteData.O3 + ' ppb' else response += '設備維護'
                    response += "\n"

                    response += '細懸浮微粒（PM2.5）濃度：'
                    if siteData['PM2.5'] isnt '' then response += siteData['PM2.5'] + ' μg/m3 ' + fpmiDesc siteData.FPMI else response += '設備維護'
                    response += "\n"

                    response += '最後更新時間：' + siteData.PublishTime
                    response += "\n"

                    msg.send response

fpmiDesc = (fpmi) ->
    switch
        when 0 <= fpmi <= 35 then '低'
        when 36 <= fpmi <= 53 then '中'
        when 54 <= fpmi <= 70 then '高'
        when fpmi <= 71 then '非常高'
        else '未定義'
