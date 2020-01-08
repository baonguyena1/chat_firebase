const functions = require('firebase-functions');
const _ = require('underscore');

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

/**
 * Trigger delete all messages in the room of the conversation when delete conversation
 */

exports.deleteRoomWhenDeleteConversationTrigger = functions.firestore
    .document('conversations/{conversationId}')
    .onDelete((snapshot, context) => {
        console.log('delete conversation ' + context.params.conversationId);
        var batch = db.batch();
        const path = 'rooms/' + context.params.conversationId + '/messages';
        deleteMessageCollection(path)
        .then(() => {
            console.log('Delete rooms message');
            const roomPath = 'rooms/' + context.params.conversationId;
            return deleteDocument(roomPath)
        })
        .then(result => {
            console.log('Delete Room ' + result);
            return snapshot;
        })
        .catch(err => {
            console.error(err);
        });
    });

function deleteMessageCollection(path) {
    let collectionRef = db.collection(path);
    let query = collectionRef.limit(batchSize);
    return new Promise((resolve, reject) => {
        deleteMessageQueryBatch(query, batchSize, resolve, reject);
    });
}

function deleteMessageQueryBatch(query, batchSize, resolve, reject) {
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
                deleteMessageQueryBatch(query, batchSize, resolve, reject);
            });
        })
        .catch(reject);
}

function deleteDocument(path) {
    let documentRef = db.doc(path);
    return documentRef.delete();
}

/**
 * Check and delete user chat when update the user chat log
 * if the conversations is null or empty, need remove it
 */

 exports.checkUserChatWhenUpdateTrigger = functions.firestore
    .document('userChats/{userId}')
    .onUpdate((snapshot, context) => {
        
        console.log('[BEGIN] checkUserChatWhenUpdateTrigger ', context.params.userId);
        let documentPath = 'userChats/' + context.params.userId;
        let documentRef = db.doc(documentPath);
        documentRef.get()
        .then(snapshot => {
            return verifyDocument(snapshot);
        })
        .then(() => {
            return deleteDocument(documentPath);
        })
        .then(result => {
            console.log('[END] checkUserChatWhenUpdateTrigger');
            return null;
        })
        .catch(err => {
            console.log(err);
        });
    });

function verifyDocument(snapshot) {
    console.log('[BEGIN] verifyDocument');
    return new Promise((resolve, reject) => {
        if (!snapshot.exists) {
            console.log('No such document!');
            return reject(new Error('No such document!'));
        }
        let conversations = snapshot.data()['conversations'];
        if (_.isUndefined(conversations) || _.isNull(conversations) || _.isEmpty(conversations)) {
            console.log('Can delete document ', snapshot);
            return resolve(null);
        }
        return reject(new Error('Conversations is not empty!'));
    });
}