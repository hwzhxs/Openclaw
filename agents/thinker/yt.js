const body = {
  context: {
    client: { clientName: "WEB", clientVersion: "2.20260101.00.00" }
  },
  videoId: "hRwjoU4RlMY"
};
fetch('https://www.youtube.com/youtubei/v1/player?prettyPrint=false', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(body)
})
.then(r => r.json())
.then(d => {
  console.log(JSON.stringify(d).substring(0, 2000));
})
.catch(e => console.log('err', e));
