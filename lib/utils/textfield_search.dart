import 'package:flutter/material.dart';
import 'dart:async';

class TextFieldSearch extends StatefulWidget {
  final List? initialList;

  final String label;

  final TextEditingController controller;

  final Function? future;

  final Function? getSelectedValue;

  final InputDecoration? decoration;

  final TextStyle? textStyle;

  final ScrollbarDecoration? scrollbarDecoration;

  final int minStringLength;

  final int itemsInView;

  const TextFieldSearch(
      {Key? key,
        this.initialList,
        required this.label,
        required this.controller,
        this.textStyle,
        this.future,
        this.getSelectedValue,
        this.decoration,
        this.scrollbarDecoration,
        this.itemsInView = 3,
        this.minStringLength = 2})
      : super(key: key);

  @override
  _TextFieldSearchState createState() => _TextFieldSearchState();
}

class _TextFieldSearchState extends State<TextFieldSearch> {
  final FocusNode _focusNode = FocusNode();
  late OverlayEntry _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  List? filteredList = <dynamic>[];
  bool hasFuture = false;
  bool loading = false;
  final _debouncer = Debouncer(milliseconds: 1000);
  static const itemHeight = 55;
  bool? itemsFound;
  ScrollController _scrollController = ScrollController();

  void resetList() {
    List tempList = <dynamic>[];
    setState(() {
      filteredList = tempList;
      loading = false;
    });
    _overlayEntry.markNeedsBuild();
  }

  void setLoading() {
    if (!loading) {
      setState(() {
        loading = true;
      });
    }
  }

  void resetState(List tempList) {
    setState(() {
      filteredList = tempList;
      loading = false;
      itemsFound = tempList.isEmpty && widget.controller.text.isNotEmpty
          ? false
          : true;
    });
    _overlayEntry.markNeedsBuild();
  }

  void updateGetItems() {
    _overlayEntry.markNeedsBuild();
    if (widget.controller.text.length > widget.minStringLength) {
      setLoading();
      widget.future!().then((value) {
        filteredList = value;
        List tempList = <dynamic>[];
        for (int i = 0; i < filteredList!.length; i++) {
          if (widget.getSelectedValue != null) {
            if (filteredList![i]

                .toLowerCase()
                .contains(widget.controller.text.toLowerCase())) {
              tempList.add(filteredList![i]);
            }
          } else {
            if (filteredList![i]
                .toLowerCase()
                .contains(widget.controller.text.toLowerCase())) {
              tempList.add(filteredList![i]);
            }
          }
        }
        resetState(tempList);
      });
    } else {
      resetList();
    }
  }

  void updateList() {
    setLoading();
    filteredList = widget.initialList;

    List tempList = <dynamic>[];
    for (int i = 0; i < filteredList!.length; i++) {
      if (filteredList![i]
          .toLowerCase()
          .contains(widget.controller.text.toLowerCase())) {
        tempList.add(filteredList![i]);
      }
    }
    resetState(tempList);
  }

  @override
  void initState() {
    super.initState();

    if (widget.scrollbarDecoration?.controller != null) {
      _scrollController = widget.scrollbarDecoration!.controller;
    }

    if (widget.initialList == null && widget.future == null) {
      throw ('Error: Missing required initial list or future that returns list');
    }
    if (widget.future != null) {
      setState(() {
        hasFuture = true;
      });
    }

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _overlayEntry = _createOverlayEntry();
        Overlay.of(context).insert(_overlayEntry);
      } else {
        _overlayEntry.remove();
        if (itemsFound == false || loading == true) {
          resetList();
          widget.controller.clear();
        }
        if (filteredList!.isNotEmpty) {
          bool textMatchesItem = false;
          if (widget.getSelectedValue != null) {
            textMatchesItem = filteredList!
                .any((item) => item == widget.controller.text);
          } else {
            textMatchesItem = filteredList!.contains(widget.controller.text);
          }
          if (textMatchesItem == false) widget.controller.clear();
          resetList();
        }
      }
    });
  }

  ListView _listViewBuilder(context) {
    if (itemsFound == false) {
      return ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        controller: _scrollController,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              widget.controller.clear();
              setState(() {
                itemsFound = false;
              });
              resetList();
              FocusScope.of(context).unfocus();
            },
            child: ListTile(
              title: Text('No matching items.'),
              trailing: Icon(Icons.cancel),
            ),
          ),
        ],
      );
    }
    return ListView.builder(
      controller: _scrollController,
      itemCount: filteredList!.length,
      itemBuilder: (context, i) {
        return GestureDetector(
            onTap: () {
              setState(() {
                if (widget.getSelectedValue != null) {
                  widget.controller.text = filteredList![i];
                  widget.getSelectedValue!(filteredList![i]);
                } else {
                  widget.controller.text = filteredList![i];
                }
              });
              resetList();
              FocusScope.of(context).unfocus();
            },
            child: ListTile(
                title: widget.getSelectedValue != null
                    ? Text(filteredList![i])
                    : Text(filteredList![i])));
      },
      padding: EdgeInsets.zero,
      shrinkWrap: true,
    );
  }

  Widget _loadingIndicator() {
    return SizedBox(
      width: 50,
      height: 50,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.secondary),
        ),
      ),
    );
  }

  Widget decoratedScrollbar(child) {
    if (widget.scrollbarDecoration is ScrollbarDecoration) {
      return Theme(
        data: Theme.of(context)
            .copyWith(scrollbarTheme: widget.scrollbarDecoration!.theme),
        child: Scrollbar(child: child, controller: _scrollController),
      );
    }

    return Scrollbar(child: child);
  }

  Widget? _listViewContainer(context) {
    if (itemsFound == true && filteredList!.isNotEmpty ||
        itemsFound == false && widget.controller.text.isNotEmpty) {
      return SizedBox(
          height: calculateHeight().toDouble(),
          child: decoratedScrollbar(_listViewBuilder(context)));
    }
    return null;
  }

  num heightByLength(int length) {
    return itemHeight * length;
  }

  num calculateHeight() {
    if (filteredList!.length > 1) {
      if (widget.itemsInView <= filteredList!.length) {
        return heightByLength(widget.itemsInView);
      }

      return heightByLength(filteredList!.length);
    }

    return itemHeight;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size overlaySize = renderBox.size;
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    return OverlayEntry(
        builder: (context) => Positioned(
          width: overlaySize.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0.0, overlaySize.height + 5.0),
            child: Material(
              elevation: 4.0,
              child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: screenWidth,
                    maxWidth: screenWidth,
                    minHeight: 0,
                    maxHeight: calculateHeight().toDouble(),
                  ),
                  child: loading
                      ? _loadingIndicator()
                      : _listViewContainer(context)),
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        decoration: widget.decoration ?? InputDecoration(labelText: widget.label),
        style: widget.textStyle,
        onChanged: (String value) {
          _debouncer.run(() {
            setState(() {
              if (hasFuture) {
                updateGetItems();
              } else {
                updateList();
              }
            });
          });
        },
      ),
    );
  }
}

class Debouncer {
  final int? milliseconds;

  VoidCallback? action;

  Timer? _timer;

  Debouncer({this.milliseconds});

  run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds!), action);
  }
}

class ScrollbarDecoration {
  const ScrollbarDecoration({
    required this.controller,
    required this.theme,
  });

  final ScrollController controller;

  final ScrollbarThemeData theme;
}
