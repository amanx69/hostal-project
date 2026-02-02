import 'package:flutter/material.dart';
import 'package:frontend/helper/widgets/SearchTextField.dart';

class Chatgroupescreen extends StatefulWidget {
  const Chatgroupescreen({super.key});

  @override
  State<Chatgroupescreen> createState() => _ChatgroupescreenState();
}

class _ChatgroupescreenState extends State<Chatgroupescreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chats"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              text: "All Chats",

            ),
            Tab(
              text: "Groups",
           
            ),
            Tab(
              text: "Friends",
            
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomTextField(
              hintText: "Search...", 
              controller: searchController
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // All Chats Tab
                Center(child: Text("All Chats")),
                // Groups Tab
                Center(child: Text("Groups")),
                // Friends Tab
                Center(child: Text("Friends")),
           
                
          
              ],
            ),
          ),
        ],
      ),
    );
  }
}