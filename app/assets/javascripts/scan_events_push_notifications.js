var beamStarted = false;
var errorCtr = 0;

pusher = function() {
  if (typeof PusherPushNotifications == 'undefined') {
    console.log("PusherPushNotifications is undefined! -> location.reload()")
    errorCtr++;
    if (errorCtr <= 5) {
      setTimeout(function(){pusher()}, 100);
    }
  }
  if (!beamStarted) {
    const beamsClient = new PusherPushNotifications.Client({
      instanceId: 'cce6bd24-139c-495e-809e-39580b8ba006',
    });
    beamsClient.start()
      .then((beamsClient) => beamsClient.getDeviceId())
      .then((deviceId) =>
        console.log("Successfully registered with Beams. Device ID:", deviceId)
      )
      .then(() => beamsClient.addDeviceInterest('scan_events'))
      .then(() => beamsClient.getDeviceInterests())
      .then((interests) => console.log("Current interests:", interests))
      .catch(console.error);
    beamStarted = true;
    errorCtr = 0;
  }
}
pusher();
