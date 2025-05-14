import 'package:flutter/material.dart';
import '../../components/app_bar.dart';
import '../../database/exportImport_helper.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const TopHeader(showBackButton: true, showIconButton: false),
              const SizedBox(height: 20),
              const Text(
                "Backup & Restore",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => exportBackup(context),
                child: const Text("Export Backup"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => importBackup(context),
                child: const Text("Import Backup"),
              ),

              SizedBox(height: 100),

              // work palace

              // i did add some notes u can take a look and it and see what can u do at same time its oki to change the design a bit to fit and u can use some icons if u want to insted of text if u think it should look more clean and nice
              // btw when u click on it it would exstand and show the note that we did add when we made the wallet and if it a goal and the amount we did set for the goal or not at same time the last 4 transactions and at the end we will see a button that says show all if u click on it it would take you into a new screen that have all the history of that wallet if there is anything import i forgot let me know as a wallet user u may wanna have or see or add
              GestureDetector(
                onTap: () {
                  print("Hardcoded wallet tapped!");
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: const [
                      CircleAvatar(
                        // here we will have the wallet icon that the user chose
                        backgroundColor: Colors.orange,
                        child: Icon(Icons.wallet, color: Colors.white),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              // here we will have the wallet name
                              "Hardcoded Wallet",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                // here we will have the wallet take income parentage and if it was 0 it would just show 0(parentage that will be taken from the income money the one that we do set when we make a new wallet )
                                Text(
                                  'in-take out : %20',
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(width: 10),
                                // here this will be a new data i think maybe we can add the date like the data of the wallet creation so i guess we will need to update the database the have something like this
                                Text('date'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      //if we can add a button the edit the wallet like a button in the top right that if u click on it we would have 2 options 1 edit 2 delete the wallet and when u click delete u will git a pop up that need you to confirm
                      // here we will have the money amount we have now lets change the size too to make it nice and clear
                      Text('\$ 100', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),

              // end of  palace
            ],
          ),
        ),
      ),
    );
  }
}
