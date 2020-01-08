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
        
        const conversationId = context.params.conversationId;
        const activeMembers = snapshot.data()['active_members'];
        const path = 'rooms/' + context.params.conversationId + '/messages';
        console.log('delete conversation ' + conversationId);

        deleteConversationInUserChat(conversationId, activeMembers)
        .then(result => {
            console.log(result);
            return deleteMessageCollection(path)
        })
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
 * 
 * @param {*} conversation : String conversation id
 * @param {*} activeMembers : [String] list id active members in conversation
 */
function deleteConversationInUserChat(conversation, activeMembers) {
    console.log('[BEGIN] deleteConversationInUserChat, conversation: ', conversation, ' active members: ', activeMembers);
    let batch = db.batch();
    activeMembers.forEach((member) => {
        let documentRef = db.doc('userChats/' + member);
        let updatedData = {
            'updated_at': Date.now(),
            'conversations': admin.firestore.FieldValue.arrayRemove(conversation)
        };
        batch.update(documentRef, updatedData)
    });
    console.log('[END] deleteConversationInUserChat');
    return batch.commit();
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

/**
 * Trigger when create new conversation
 */
exports.createUserChatsWhenCreateNewConversationTrigger = functions.firestore
.document('conversations/{conversationId}')
.onCreate((snapshot, context) => {
    
    let conversationId = context.params.conversationId;
    let members = snapshot.data()['active_members'];
    console.log('[BEGIN] checkWhenCreateNewConversationTrigger');
    let batch = db.batch();
    createUserChatLog(members, conversationId, batch)
    .then(() => {
        return batch.commit();
    })
    .then(result => {
        console.log(result);
        return;
    })
    .catch(err => {
        console.error(err);
    })
});

/**
 * Create user chats when create new conversation
 * @param {[String]} users : list user id in conversation
 * @param {String} conversation : conversation id
 * @param {Batch} batch: firebase batch
 */
function createUserChatLog(users, conversation, batch) {
    var promises = [];
    users.forEach(user => {
        
        let documentRef = db.doc('userChats/' + user);
        let promise = documentRef.get()
        .then(snapshot => {
            var updatedData = {
                'created_at': Date.now(),
                'updated_at': Date.now(),
            };
            if (snapshot.exists) {
                updatedData.conversations = admin.firestore.FieldValue.arrayUnion(conversation)
                batch.update(documentRef, updatedData);
            } else {
                updatedData.conversations = [conversation];
                batch.create(documentRef, updatedData);
            }
            return;
        });
        promises.push(promise);
    });
    return Promise.all(promises);
}

exports.updateLastMessageSendConversationWhenCreateMessageTrigger = functions.firestore
.document('rooms/{conversationId}/messages/{messageId}')
.onCreate((snapshot, context) => {

    let conversationId = context.params.conversationId;
    let messageId = context.params.messageId;
    console.log('[BEGIN] updateLastMessageSendConversationWhenCreateMessageTrigger', conversationId, messageId);
    let updatedData = {
        'last_message_id': messageId,
        'updated_at': Date.now()
    }
    let documentRef = db.doc('conversations/' + conversationId);

    documentRef.update(updatedData)
    .then(result => {
        console.log(result);
        console.log('[END] updateLastMessageSendConversationWhenCreateMessageTrigger');
        return;
    })
    .catch(err => {
        console.error(err);
    })
});