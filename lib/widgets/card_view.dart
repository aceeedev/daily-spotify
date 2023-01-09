import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daily_spotify/providers/setup_provider.dart';
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';
import 'package:daily_spotify/styles.dart';

/// A [GridView] of custom [Card]s.
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
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: widget.type == Artist ? 7 / 8 : 7 / 9),
      itemCount: widget.itemList.length,
      itemBuilder: (context, index) {
        dynamic item = widget.itemList[index];
        bool selected = false;
        switch (widget.type) {
          case Artist:
            {
              selected = context
                      .read<SetupForm>()
                      .selectedArtistList
                      .indexWhere(
                          (element) => element.id == (item as Artist).id) !=
                  -1;
            }
            break;
          case Track:
            {
              selected = context.read<SetupForm>().selectedTrackList.indexWhere(
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
          color: widget.selected ? Styles().selectedColor : null,
          elevation: widget.selected
              ? Styles().selectedElevation
              : Styles().unselectedElevation,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(children: [
              AspectRatio(
                aspectRatio: widget.type == Artist ? 8 / 7 : 3 / 2,
                child: Image.network(
                    (widget.item.images[1] as SpotifyImage).url,
                    width: (widget.item.images[1] as SpotifyImage)
                        .width
                        .toDouble(),
                    height: (widget.item.images[1] as SpotifyImage)
                        .height
                        .toDouble()),
              ),
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
