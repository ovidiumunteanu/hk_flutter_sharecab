const serviceAccount = {
    "type": "service_account",
    "project_id": "share-project-2fdb3",
    "private_key_id": "ab1014b5c1fa1945ec3aa179e7c5afac7420dcd8",
    "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC9lSPpqGjEJGPr\nkoOD/gbxWTXen7OEy1cyJLjQb+u0MWbDbY+iit2vV2+MFwNKrX9Bqi/OthI+ifxs\n0t/7cqQmFHOxjOhaqycCoGreXpYp111WXM4Q9xpzlkDsKftibxDlnaBQmp1OVvfv\nb3ABVtQh/AKQogh5oLba5SF8/IPzXCCrBYjusAzv6osOiaxXxwNIkPyfQfxDnTEq\n+mLLXC9vYzNv1Ym/R9iW+VvNQpmUUAD9VVKu/QYCOmC+Hx5R1u+tGw1kCIZvoN77\nQguHwObqPSXPzTTGdvVnaf4nNmW9Le/d/d/vo1wOcq6tjG1rut6OWYviTqUvVgqr\nIECV5RpxAgMBAAECggEAB4hOi63NMW0QUUXnFs5eU6ZYc+N2T2jnqoGqz14bCECy\nog71o+vB87UIJN56Z+dHBQKWveJRc3QQRPlt781cXnnCjQPmhklPL/uhGciG5w7i\nnpgdkeJkUsJeCv2yByh9jEbI6o4lTbCgtXE0JI5HUgbAY7zxLdzBilnycvpZFC97\n3v+59KTZA5iwwVWixuJtrbBgqEwry4THvUiIL8JKzvdWzx7TF+0lifstflUdMI54\nVpcGkVUMQfSwQ1Qnc5oKuuFkh9yfE/Na6I0MG/nZJmEDV/qI7x24kFm/PYE98V5p\nn6TVxhYMCY0b/abzxbeVu3jLu2v6Xb9iPXn3UefS6QKBgQDkgWOZOr20QQQRQLXH\nKrmDbpQbrhjOIK1nJNmv1xgEjlAkqCqi2pYecSDcxbGEz0wLpJXvg4ME23/20pC8\n5HoW9UflYGJli3E3UaT7s5btpNLsK+nnI/g5GyGF8bKBm0FWKyeUp40jImCo5BvF\nY+VtvX3PFG2SEIMxuqDini2LDQKBgQDUZNFgmZGUe7o1sIfvyDYi4k87WCHYwvSA\npVmlQAT0atPTFm76Z1cBnpLfZ+TkRi83kzBky9DCAPiV8YgwUFdMa/QhNyQGi8Jc\n+4sBZNtg/+kY5ICEGwXPqyy8bxRwCEnNiLasreOUFsYAhWIBUov8QkpUo4PBk4H3\nNFVoL21j9QKBgD+0bu8GOGMriRXCQ6tuFuA0kOgSpmm5JH7QADyMq+6BOoittY1H\ngXilM3M5Tl9nZ50LWp22vW06QLewRpfS3tLNuSiSsXv73yl8ApIFpHtGa2NabtB4\n77gD/1mXY5vMi++ZAmToPWnhKK+NQMzMJ+drX8q+uDlzjw/rJvVnAe11AoGBANN7\nr5/oSbT3nepn5HM1f/IsNYh5sPoM5ThTbHfGzygwVssQw2BCFbhfFQ+ue5Nw7wL/\nZGh5KVyDawKihWDWHpbRxzxrk0uRTe8X6Mlyi56CMq++ltjzr02gu+LFGCyVlCc7\nwekfHEQQiQdryLJYZ1q/BxRP3JmbLwXe7kvXLa0hAoGBAL0VLPFAcYT2v+GwNuyv\n0pJjdamnwLZabZ4OZG3qQTU7kHGVt18xa7YO3lnprFOwkrONtcuIvcJQO3bheEuE\n9k0txv14IZ9WjXqNTLWMzoXrLGdyUaVYhZKX77hMjybkCbQlHeosWKZw8sZNgOuX\nFJ6faJDg0e/KmEH1Kb/Gs6Gw\n-----END PRIVATE KEY-----\n",
    "client_email": "firebase-adminsdk-foqkf@share-project-2fdb3.iam.gserviceaccount.com",
    "client_id": "114709452777945480735",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-foqkf%40share-project-2fdb3.iam.gserviceaccount.com"
}

var moment = require('moment');
var admin = require("firebase-admin");
const functions = require('firebase-functions');
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
});

let db = admin.firestore();
db.settings({ ignoreUndefinedProperties: true })

exports.manual_remove = functions.https.onRequest(async (req, res) => {
    try {
        let group_ref = await db.collection('group').get();
        for (var p = 0; p < group_ref.docs.length; p++) {
            let departure_time = group_ref.docs[p].data().departure_time;
           
            if (departure_time._seconds * 1000  < (new Date().getTime() - 90 * 60 * 1000)) // 90 mins   
            {
                let group_id = group_ref.docs[p].id

                try {
                    let users_ref = await db.collection('userdetails').where('currentGroup', '==', group_id).get();
                    for (var u = 0; u < users_ref.docs.length; u++) {
                        await db.collection('userdetails').doc(users_ref.docs[u].id).update({
                            currentGroup: null
                        });
                    }
                }
                catch (error) {
                    console.log(error);
                }

                try {
                    await db.collection('chatroom').doc(group_id).delete();
                } 
                catch (error) {
                    console.log(error);
                }

                // delete group
                try {
                    let group_users_ref = await db.collection('group').doc(group_id).collection('users').get();
                    for (var u = 0; u < group_users_ref.docs.length; u++) {
                        await db.collection('group').doc(group_id).collection('users').doc(group_users_ref.docs[u].id).delete();
                    }
                    await db.collection('group').doc(group_id).delete();
                } 
                catch (error) {
                    console.log(error);
                }
            }
        }
    }
    catch (error) {
        console.log(error);
    }
    res.send("Hello");
});

exports.scheduler = functions.pubsub.schedule('every 5 minutes').onRun(async (context) => {
    try {
        let group_ref = await db.collection('group').get();
        for (var p = 0; p < group_ref.docs.length; p++) {
            let departure_time = group_ref.docs[p].data().departure_time;
           
            if (departure_time._seconds * 1000  < (new Date().getTime() - 90 * 60 * 1000)) // 90 mins   
            {
                let group_id = group_ref.docs[p].id

                try {
                    let users_ref = await db.collection('userdetails').where('currentGroup', '==', group_id).get();
                    for (var u = 0; u < users_ref.docs.length; u++) {
                        await db.collection('userdetails').doc(users_ref.docs[u].id).update({
                            currentGroup: null
                        });
                    }
                }
                catch (error) {
                    console.log(error);
                }

                try {
                    await db.collection('chatroom').doc(group_id).delete();
                } 
                catch (error) {
                    console.log(error);
                }

                // delete group
                try {
                    let group_users_ref = await db.collection('group').doc(group_id).collection('users').get();
                    for (var u = 0; u < group_users_ref.docs.length; u++) {
                        await db.collection('group').doc(group_id).collection('users').doc(group_users_ref.docs[u].id).delete();
                    }
                    await db.collection('group').doc(group_id).delete();
                } 
                catch (error) {
                    console.log(error);
                }
            }
        }
    }
    catch (error) {
        console.log(error);
    }
    return true;
})
