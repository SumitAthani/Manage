import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manage/api/routeUrls.dart';
import 'package:manage/screens/drawer.dart';
import 'package:manage/widgets/button.dart';
import 'package:manage/widgets/card.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import "dart:convert";

var addTransactionUrl = Uri.parse(Urls.addExpenditures);
var getTransactionUrl = Uri.parse(Urls.getExpenditures);

class AddList extends StatefulWidget {
  const AddList({Key? key, required this.setDark, required, this.dark})
      : super(key: key);

  final setDark;
  final dark;

  @override
  _AddListState createState() => _AddListState(setDark: setDark, dark: dark);
}

class _AddListState extends State<AddList> {
  late List data = [];
  final bool dark;
  _AddListState({required this.setDark, required this.dark});
  late List<Item> allTrans;
  final setDark;

  getData() async {
    const storage = FlutterSecureStorage();
    var token = await storage.read(key: "jwt");

    print("getting data");

    var response = await http.get(
      getTransactionUrl,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token.toString(),
      },
    );

    data = jsonDecode(response.body);
    data = List.from(data.reversed);
    setState(() {
      allTrans = generateItems(data.length);
    });

    // if (data.length == 0)
    setState(() {
      loading = false;
    });
    print(data);
  }

  var loading = true;
  Widget _loading() {
    return const Center(
      child: Text("Loading"),
    );
  }

  @override
  initState() {
    super.initState();

    getData();
  }

  Widget _buildPanel() {
    return ExpansionPanelList(
      animationDuration: const Duration(milliseconds: 500),
      expansionCallback: (int index, bool isExpanded) {
        if (allTrans[index].isExpanded == false) {
          allTrans.forEach((element) {
            element.isExpanded = false;
          });
        }

        setState(() {
          allTrans[index].isExpanded = !isExpanded;
        });
      },
      children: allTrans.map<ExpansionPanel>((Item item) {
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(item.headerValue),
            );
          },
          body: item.expandedValue,
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }

  double total = 0;

  List<Widget> generateTransactionCard(int num, List transactons) {
    total = 0;
    return List.generate(num, (index) {
      if (index < num - 1) {
        print("index $index $num");
        var cost = transactons[index]["cost"].toString();
        double Cost = double.parse(cost);
        total += Cost;
        print(Cost);
        Color shadow = Colors.green;
        if (Cost > 100) {
          shadow = Colors.red;
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
          child: Card(
              shadowColor: shadow,
              elevation: 5,
              // color: shadow,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(transactons[index]["item"]),
                    Text("₹ " + Cost.toString())
                  ],
                ),
              )),
        );
      } else {
        Color? color = Colors.green[400];
        if (total > 150) {
          color = Colors.red[300];
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
          child: Card(
              color: color,
              elevation: 5,
              // color: shadow,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total",
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    Text(
                      "₹ " + total.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    )
                  ],
                ),
              )),
        );
      }
    });
  }

  List<Item> generateItems(int numberOfItems) {
    return List.generate(numberOfItems, (int index) {
      var transactions = data[index]["transactions"];
      List<Widget> trans =
          generateTransactionCard(transactions.length + 1, transactions);

      return Item(
        headerValue: data[index]["date"],
        expandedValue: Column(
          children: trans,
        ),
      );
    });
  }

  ScrollController diplayTrasnsController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(setDark: setDark, dark: dark),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Add Your Transactions",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () {
          print("refreshingsds");
          return Future.delayed(const Duration(seconds: 1), () {
            getData();
          });
        },
        child: Material(
          child: Container(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (data.isNotEmpty)
                  Expanded(
                      child: Scrollbar(
                    radius: const Radius.circular(10),
                    showTrackOnHover: true,
                    controller: diplayTrasnsController,
                    thickness: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListView(
                          controller: diplayTrasnsController,
                          children: [loading ? _loading() : _buildPanel()]),
                    ),
                  )),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MyButton(
                    title: "Add list",
                    onTap: () {
                      showModalBottomSheet(
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(15))),
                          enableDrag: true,
                          context: context,
                          builder: (context) => Show(
                                getData: getData,
                              ));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Item {
  Item({
    required this.expandedValue,
    required this.headerValue,
    this.isExpanded = false,
  });

  Widget expandedValue;
  String headerValue;
  bool isExpanded;
}

class Show extends StatefulWidget {
  const Show({Key? key, required this.getData}) : super(key: key);

  final Function getData;

  @override
  _ShowState createState() => _ShowState(getData: getData);
}

class _ShowState extends State<Show> {
  var getData;

  _ShowState({Key? key, required this.getData});

  var list = <Map>[
    {"title": "Food", "description": "breakfast, lunch, snacks, dinner..."},
    {"title": "Extra Food", "description": "Pizza, burger..."},
    {"title": "Travel", "description": "Travel Charges..."},
    {"title": "Helped", "description": "Lended some money..."}
  ];

  List<Widget> customTransactionList = [];

  void addCustomTransactionList() {
    customTransactionList.add(CustomTransactionInput(
        addCost: addCost,
        addToList: addToList,
        delete: deleteCustomTransactionList,
        key: Key(customTransactionList.length.toString())));
    setState(() {
      customTransactionList;
    });
  }

  void deleteCustomTransactionList(Key index) {
    List<Widget> list = [];

    customTransactionList.forEach((element) {
      if (element.key != index) {
        list.add(element);
      }
    });
    setState(() {
      customTransactionList = list;
    });
  }

  var costList = <double>[10, 20, 50, 100, 200, 500];

  var myAddedList = <Map>[];

  var costOrList = false;

  void addToList(String title) async {
    myAddedList.add({"item": title});
    setState(() {
      costOrList = true;
      myAddedList;
    });
  }

  void delelteEntry(int i) {
    List<Widget> list = [];
    print(i);
    myAddedList.removeAt(i);
    setState(() {
      myAddedList;
      costOrList = false;
    });
  }

  void addCustomCost(double cost, int index) {
    print("here $cost");
    List<Widget> list = [];

    myAddedList[index]["cost"] = cost;
    setState(() {
      myAddedList;
      costOrList = false;
    });
  }

  void addCost(double cost) {
    myAddedList.last["cost"] = cost;
    setState(() {
      myAddedList;
      costOrList = false;
    });
  }

  var MONTHS = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];

  String formattedDateTime() {
    DateTime now = new DateTime.now();
    return now.day.toString() +
        " " +
        MONTHS[now.month - 1] +
        " " +
        now.year.toString() +
        " ";
  }

  Future<void> saveList() async {
    String date = formattedDateTime();
    const storage = FlutterSecureStorage();
    var token = await storage.read(key: "jwt");
    var data = {"date": date, "transactions": myAddedList};
    String body = jsonEncode(data);

    var response = await http.post(
      addTransactionUrl,
      body: body,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token.toString(),
      },
    );

    print(body);
    print(token.toString());
    print(response.body);
    Navigator.pop(context);
    getData();
  }

  final costEditor = TextEditingController();
  final customCostField = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 5,
          width: 30,
          margin: const EdgeInsets.only(top: 8, bottom: 8),
          decoration: BoxDecoration(
              color: Colors.grey, borderRadius: BorderRadius.circular(5)),
        ),
        Expanded(
          child: Row(
            children: [
              left(
                  myAddedList,
                  customTransactionList,
                  addCustomTransactionList,
                  addToList,
                  addCost,
                  addCustomCost,
                  delelteEntry,
                  saveList,
                  costEditor,
                  customCostField),
              if (!costOrList)
                right(list, addToList)
              else
                rightCost(costList, addCost)
            ],
          ),
        )
      ],
    );
  }
}

class Right extends StatelessWidget {
  const Right({Key? key, required this.list, required this.addToList})
      : super(key: key);

  final List<Map> list;
  final addToList;

  // final void addToList(int index);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        flex: 3,
        // child: Text("dfs"),
        child: ListView.builder(
            itemCount: list.length,
            itemBuilder: (BuildContext context, int i) => MyCard(
                title: list[i]["title"],
                description: list[i]["description"],
                key: Key(i.toString()),
                onTap: () {
                  addToList(i);
                })));
  }
}

Widget rightCost(costList, addCost) {
  return Expanded(
      flex: 2,
      // child: Text("dfs"),
      child: ListView.builder(
        itemCount: costList.length,
        itemBuilder: (BuildContext context, int i) {
          double cost = costList[i];
          return MyCard(
              title: cost.toString() + " ₹",
              description: "",
              onTap: () {
                addCost(cost);
              });
        },
      ));
}

Widget left(
    myAddedList,
    customTransactionList,
    addToCustomTransactionList,
    addToList,
    addCost,
    addCustomCost,
    delete,
    saveList,
    costEditor,
    customCostField) {
  double total = 0;

  final ScrollController _scroll = ScrollController();

  final ScrollController _scrollController = ScrollController();

  myAddedList.forEach((i) {
    if (i["cost"] != null) total += i["cost"];
  });

  if (customTransactionList.length > 0) {
    WidgetsBinding.instance!.addPostFrameCallback(((_) {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 500),
      );
    }));
  }

  if (myAddedList.length > 0) {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 500),
      );
    });
  }

  int indexToSave = 0;

  return Expanded(
    flex: 6,
    child: Column(
      children: [
        Expanded(
          flex: 2,
          child: ListView.builder(
            controller: _scrollController,
            itemBuilder: (BuildContext context, int i) {
              return Card(
                key: Key(i.toString()),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(myAddedList[i]["item"]),
                      ),
                      if (myAddedList[i]["cost"] != null)
                        Text(myAddedList[i]["cost"].toString())
                      else
                        Expanded(
                          flex: 1,
                          child: Form(
                            key: customCostField,
                            child: TextFormField(
                              maxLines: 1,
                              controller: costEditor,
                              onChanged: (value) {
                                customCostField.currentState.validate();
                                indexToSave = i;
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Required";
                                } else if (double.parse(value) > 5000) {
                                  return ">5000";
                                }
                              },
                              onEditingComplete: () {
                                print("here");
                                FocusManager.instance.primaryFocus?.unfocus();
                                addCustomCost(double.parse(costEditor.text), i);
                              },
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                            ),
                          ),
                        ),
                      const SizedBox(
                        width: 10,
                      ),
                      InkWell(
                        splashColor: Colors.red,
                        onTap: () {
                          delete(i);
                        },
                        child: const Icon(
                          Icons.close,
                          size: 15,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            itemCount: myAddedList.length,
          ),
        ),
        Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.amber.withOpacity(.5),
            ),
            child: InkWell(
                onTap: () {
                  addToCustomTransactionList();
                },
                splashColor: Colors.red,
                borderRadius: BorderRadius.circular(20),
                child: const Icon(Icons.add))),
        Container(
          color: Colors.amber,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(7),
                  child: const Text("Total:"),
                ),
              ),
              Container(
                  padding: const EdgeInsets.all(8), child: Text("₹ $total"))
            ],
          ),
        ),
        if (customTransactionList.length > 0)
          Expanded(
              child: ListView.builder(
            controller: _scroll,
            itemCount: customTransactionList.length,
            itemBuilder: (BuildContext context, int index) {
              return customTransactionList[index];
            },
          )),
        if (myAddedList.length > 0)
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Material(
              // padding: EdgeInsets.all(8),
              color: Colors.amber,
              clipBehavior: Clip.hardEdge,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                onTap: () async {
                  if (customCostField.currentState != null &&
                      customCostField.currentState.validate()) {
                    print("here savdsadvsadv");
                    addCustomCost(double.parse(costEditor.text), indexToSave);
                    saveList();
                  } else {
                    if (costEditor.text == null) {
                      print("dfsadfsdfsadfsa   dfsadf ddfsa  1");
                    }
                    if (costEditor.text == "" &&
                        myAddedList[indexToSave]["cost"] == null) {
                      print("entered");
                      await delete(indexToSave);
                      print("deleted");
                      saveList();
                      // print("herererererererererererer");
                    } else {
                      saveList();
                    }
                  }
                },
                splashColor: Colors.red,
                child: const Padding(
                  padding: EdgeInsets.all(9),
                  child: Text(
                    "Save",
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
          )
      ],
    ),
  );
}

class CustomTransactionInput extends StatelessWidget {
  CustomTransactionInput(
      {Key? key,
      required this.addCost,
      required this.addToList,
      required this.delete})
      : super(key: key);

  Function addCost;
  Function addToList;
  Function delete;

  final textController = TextEditingController();
  final costController = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formkey,
      child: Container(
          child: Row(
        children: [
          Expanded(
              flex: 4,
              child: TextFormField(
                onChanged: (value) {
                  _formkey.currentState!.validate();
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Provide a name";
                  }
                },
                controller: textController,
                decoration: const InputDecoration(hintText: "Transaction Name"),
              )),
          Expanded(
              child: TextFormField(
            // key: _formkey,
            controller: costController,

            maxLines: 1,
            onChanged: (value) {
              _formkey.currentState!.validate();
            },
            validator: (value) {
              if (value!.isEmpty) {
                return "Required";
              } else if (double.parse(value) > 5000) {
                return ">5000";
              }
            },

            decoration: const InputDecoration(hintText: "cost"),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          )),
          Expanded(
            child: Container(
              child: InkWell(
                onTap: () {
                  if (_formkey.currentState!.validate()) {
                    addToList(textController.text);
                    addCost(double.parse(costController.text));
                    delete(key);
                  } else {}
                },
                child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                        // color: Colors.amber,
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.check)),
              ),
            ),
          ),
          Expanded(
            child: Container(
              child: InkWell(
                onTap: () {
                  delete(key);
                },
                child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                        // color: Colors.amber,
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(
                      Icons.close,
                      color: Colors.red,
                    )),
              ),
            ),
          ),
        ],
      )),
    );
  }
}

Widget right(list, addToList) => Expanded(
    flex: 2,
    // child: Text("dfs"),
    child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (BuildContext context, int i) => MyCard(
            title: list[i]["title"],
            description: list[i]["description"],
            key: Key(i.toString()),
            onTap: () {
              addToList(list[i]["title"]);
            })));
