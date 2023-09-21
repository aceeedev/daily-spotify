import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:daily_spotify/providers/setup_provider.dart';
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';
import 'package:daily_spotify/styles.dart';

/// A [MasonryGridView] of custom [Card]s.
///
/// The parameter [type] can either be [Artist] or [Track].
class CardView extends StatefulWidget {
  const CardView({super.key, required this.itemList, required this.type});

  final List<dynamic> itemList;
  final Type type;

  @override
  State<CardView> createState() => _CardViewState();
}

class _CardViewState extends State<CardView> {
  @override
  Widget build(BuildContext context) {
    return MasonryGridView.builder(
      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2),
      itemCount: widget.itemList.length,
      physics: const ScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        dynamic item = widget.itemList[index];
        bool selected = false;
        switch (widget.type) {
          case Artist:
            {
              selected = context
                      .watch<SetupForm>()
                      .selectedArtistList
                      .indexWhere(
                          (element) => element.id == (item as Artist).id) !=
                  -1;
            }
            break;
          case Track:
            {
              selected = context
                      .watch<SetupForm>()
                      .selectedTrackList
                      .indexWhere(
                          (element) => element.id == (item as Track).id) !=
                  -1;
            }
            break;
          default:
            {
              throw Exception(
                  'Invalid Type, must be either Artist or Track but was ${widget.type}');
            }
        }

        return CustomCard(item: item, selected: selected, type: widget.type);
      },
    );
  }
}

// ignore: must_be_immutable
class CustomCard extends StatefulWidget {
  CustomCard(
      {super.key,
      required this.item,
      required this.selected,
      required this.type});

  final dynamic item;
  bool selected;
  final Type type;

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.selected) {
          switch (widget.type) {
            case Artist:
              {
                context
                    .read<SetupForm>()
                    .removeFromSelectedArtistList(widget.item);
              }
              break;
            case Track:
              {
                context
                    .read<SetupForm>()
                    .removeFromSelectedTrackList(widget.item);
              }
              break;
            default:
              {
                throw Exception(
                    'Invalid Type, must be either Artist or Track but was ${widget.type}');
              }
          }

          setState(() {
            widget.selected = false;
          });
        } else {
          final dynamic addedItem;
          switch (widget.type) {
            case Artist:
              {
                addedItem = context
                    .read<SetupForm>()
                    .addToSelectedArtistList(widget.item);
              }
              break;
            case Track:
              {
                addedItem = context
                    .read<SetupForm>()
                    .addToSelectedTrackList(widget.item);
              }
              break;
            default:
              {
                throw Exception(
                    'Invalid Type, must be either Artist or Track but was ${widget.type}');
              }
          }

          if (addedItem != null) {
            setState(() {
              widget.selected = true;
            });
          }
        }
      },
      child: Card(
          color: widget.selected
              ? Styles().selectedColor
              : Styles().secondaryColor,
          elevation: widget.selected
              ? Styles().selectedElevation
              : Styles().unselectedElevation,
          shadowColor: Styles().shadowColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: [
              widget.item.images != null && widget.item.images.isNotEmpty
                  ? AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                          decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.fitWidth,
                          alignment: FractionalOffset.topCenter,
                          image: NetworkImage(
                              (widget.item.images[1] as SpotifyImage).url),
                        ),
                      )),
                    )
                  : const SizedBox.shrink(),
              Text(
                widget.item.name,
                textAlign: TextAlign.center,
                style: Styles().titleText,
              ),
              widget.type == Track
                  ? Text(
                      (widget.item as Track).getArtists(),
                      textAlign: TextAlign.center,
                      style: Styles().subtitleText,
                    )
                  : const SizedBox.shrink(),
            ]),
          )),
    );
  }
}
