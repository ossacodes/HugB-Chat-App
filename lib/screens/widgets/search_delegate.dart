// import 'package:flutter/material.dart';
// import 'package:flutter_mongodb_realm/mongo_realm_client.dart';
// import 'package:get/get.dart';
// import 'package:hugb/screens/chat_screen.dart';

// class UserSearchDelegate extends SearchDelegate<String> {
//   final List<String> users; // This should be your list of users
//   UserSearchDelegate(this.users);

//   final client = MongoRealmClient();

//   @override
//   List<Widget> buildActions(BuildContext context) {
//     return [
//       IconButton(
//         icon: const Icon(Icons.clear),
//         onPressed: () {
//           query = '';
//         },
//       ),
//     ];
//   }

//   @override
//   Widget buildLeading(BuildContext context) {
//     return IconButton(
//       icon: const Icon(Icons.arrow_back),
//       onPressed: () {
//         close(context, '');
//       },
//     );
//   }

//   @override
//   Widget buildResults(BuildContext context) {
//     // final results = users.where((user) => user.contains(query)).toList();
//     final collection = client.getDatabase('hugb-db').getCollection('users');
//     var docs = collection.find(
//       filter: {
//         "username": query,
//       },
//     );

//     return FutureBuilder(
//       future: docs,
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const Center(
//             child: CircularProgressIndicator(),
//           );
//         }

//         return ListView.builder(
//           itemCount: snapshot.data!.length,
//           itemBuilder: (context, index) {
//             return ListTile(
//               leading: const CircleAvatar(
//                 child: Icon(Icons.person),
//               ),
//               title: Text(
//                 snapshot.data![index].get('username'),
//               ),
//               onTap: () {
//                 // Handle user tap
//               },
//             );
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget buildSuggestions(BuildContext context) {
//     // final suggestions = users.where((user) => user.contains(query)).toList();
//     final collection = client.getDatabase('hugb-db').getCollection('users');
//     var docs = collection.find();

//     return FutureBuilder(
//       future: docs,
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const Center(
//             child: CircularProgressIndicator(),
//           );
//         }

//         return ListView.builder(
//           itemCount: snapshot.data!.length,
//           itemBuilder: (context, index) {
//             return ListTile(
//               leading: const CircleAvatar(
//                 child: Icon(Icons.person),
//               ),
//               title: Text(
//                 snapshot.data![index].get('username'),
//               ),
//               onTap: () {
//                 Get.to(
//                   ChatScreen(
//                     username: snapshot.data![index].get('username'),
//                     avatar: '',
//                     userId: snapshot.data![index].get('userId'),
//                     email: snapshot.data![index].get('email'),
//                     docId: snapshot.data![index].get('_id'),
//                   ),
//                 );
//               },
//             );
//           },
//         );
//       },
//     );
//   }
// }
