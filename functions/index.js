const functions = require('firebase-functions');

// The Firebase Admin SDK to access the Firebase Realtime Database.
const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();

const batchSize = 10;

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

exports.deleteMessageRoom = functions.firestore
    .document('conversations/{conversationId}')
    .onDelete((snapshot, context) => {
        console.log('delete conversation ' + context.params.conversationId);
        var batch = db.batch();
        const path = 'rooms/' + context.params.conversationId + '/messages';
        deleteCollection(path)
        .then(() => {
            console.log('Delete rooms message');
            const roomPath = 'rooms/' + context.params.conversationId;
            return deleteRoom(roomPath)
        })
        .then(result => {
            console.log('Delete Room ' + result);
            return snapshot;
        })
        .catch(err => {
            console.error(err);
        });
    });

function deleteCollection(path) {
    let collectionRef = db.collection(path);
    let query = collectionRef.limit(batchSize);
    return new Promise((resolve, reject) => {
        deleteQueryBatch(query, batchSize, resolve, reject);
    });
}

function deleteQueryBatch(query, batchSize, resolve, reject) {
    query.get()
        .then(snapshot => {
            if (snapshot.size === 0) {
                return 0;
            }
            let batch = db.batch();
            snapshot.docs.forEach(doc => {
                batch.delete(doc.ref);
            });
            return batch.commit()
                .then(() => {
                    return snapshot.size;
                });
        })
        .then((numDeleted) => {
            if (numDeleted === 0) {
                return resolve();
            }
            return process.nextTick(() => {
                deleteQueryBatch(query, batchSize, resolve, reject);
            });
        })
        .catch(reject);
}

function deleteRoom(path) {
    let documentRef = db.doc(path);
    return documentRef.delete();
}