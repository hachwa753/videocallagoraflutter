const functions = require("firebase-functions");
const {RtcTokenBuilder, RtcRole} = require("agora-access-token");

const APP_ID = "6e0e73a5a42444499d40dde03af428ad";
const APP_CERTIFICATE = "Yb2f1f2a407504d579c3a11aae0ff7e46";

exports.generateToken = functions.https.onRequest((req, res) => {
  const channelName = req.query.channelName;
  const uid = req.query.uid;

  if (!channelName || !uid) {
    return res.status(400).send("channelName and uid are required");
  }

  const role = RtcRole.PUBLISHER;
  const expireTime = 3600; // 1 hour
  const currentTimestamp = Math.floor(Date.now() / 1000);
  const privilegeExpireTs = currentTimestamp + expireTime;

  const token = RtcTokenBuilder.buildTokenWithUid(
      APP_ID,
      APP_CERTIFICATE,
      channelName,
      Number(uid),
      role,
      privilegeExpireTs,
  );

  res.json({token});
});
