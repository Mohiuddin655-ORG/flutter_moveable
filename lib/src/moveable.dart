part of '../flutter_moveable.dart';

class Moveable extends StatefulWidget {
  final int movingAnimationTime;
  final int movedAnimationTime;
  final Curve animationCurve;
  final Alignment alignment;
  final MovingType type;
  final MoveableObject object;
  final Widget child;
  final void Function()? onInit;
  final void Function(DragUpdateDetails details)? onDragging;
  final void Function(DragEndDetails details)? onDragged;

  const Moveable({
    super.key,
    this.alignment = Alignment.topLeft,
    this.type = MovingType.anywhere,
    required this.object,
    required this.child,
    this.movingAnimationTime = 50,
    this.movedAnimationTime = 200,
    this.animationCurve = Curves.decelerate,
    this.onInit,
    this.onDragged,
    this.onDragging,
  });

  @override
  State<Moveable> createState() => _MoveableState();
}

class _MoveableState extends State<Moveable> {
  BoxConstraints constraints = const BoxConstraints();
  Offset offset = Offset.zero;
  Size objectSize = Size.zero;

  bool draggingMode = false;

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback(_onPanInit);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant Moveable oldWidget) {
    SchedulerBinding.instance.addPostFrameCallback(_onPanInit);
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, con) {
        constraints = con;
        return Stack(
          children: [
            widget.child,
            AnimatedPositioned(
              curve: widget.animationCurve,
              duration: Duration(
                milliseconds: draggingMode
                    ? widget.movingAnimationTime
                    : widget.movedAnimationTime,
              ),
              left: offset.dx,
              top: offset.dy,
              child: GestureDetector(
                onPanUpdate: _onPanUpdate,
                onPanEnd:
                    widget.type != MovingType.anywhere ? _onPanEndHandle : null,
                child: widget.object._(context, draggingMode),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onPanInit([Duration? duration]) {
    objectSize = Size(widget.object.width, widget.object.height);
    offset = _initial();
    setState(() {});
  }

  void _onPanUpdate(DragUpdateDetails details) {
    draggingMode = true;
    offset = _update(details.delta);
    setState(() => widget.onDragging?.call(details));
  }

  void _onPanEndHandle(DragEndDetails details) {
    draggingMode = false;
    offset = _finalization();
    setState(() => widget.onDragged?.call(details));
  }

  Offset _initial() {
    return MoveablePosition(
      type: widget.type,
      constraints: constraints,
      objectSize: objectSize,
      margin: widget.object.margin,
    ).initial(widget.alignment);
  }

  Offset _update(Offset delta) {
    return MoveablePosition(
      type: widget.type,
      constraints: constraints,
      objectSize: objectSize,
      margin: widget.object.margin,
    ).update(offset, delta);
  }

  Offset _finalization() {
    return MoveablePosition(
      type: widget.type,
      constraints: constraints,
      objectSize: objectSize,
      margin: widget.object.margin,
    ).finalization(offset);
  }
}

class MoveableObject {
  final double width;
  final double height;
  final double spacer;
  final EdgeInsets margin;
  final Widget child;
  final Widget? Function(
    bool dragging,
    Widget? child,
  )? builder;

  const MoveableObject({
    required double maxWidth,
    required double maxHeight,
    this.margin = EdgeInsets.zero,
    this.spacer = 0,
    required this.child,
    this.builder,
  })  : width = maxWidth + (spacer * 2),
        height = maxHeight + (spacer * 2);

  const MoveableObject.rational({
    required double maxWidth,
    required double ratio,
    this.spacer = 0,
    this.margin = EdgeInsets.zero,
    required this.child,
    this.builder,
  })  : width = maxWidth + (spacer * 2),
        height = (maxWidth + (spacer * 2)) / ratio;

  Widget _(BuildContext context, bool dragging) {
    return Container(
      width: width - (spacer * 2),
      height: height - (spacer * 2),
      margin: EdgeInsets.all(spacer),
      child: builder?.call(dragging, child) ?? child,
    );
  }
}

class MoveablePosition {
  final MovingType type;
  final BoxConstraints constraints;
  final Size objectSize;
  final EdgeInsets margin;

  const MoveablePosition({
    this.type = MovingType.anywhere,
    required this.constraints,
    required this.objectSize,
    required this.margin,
  });

  Alignment alignment(Offset offset) {
    double x = offset.dx;
    double y = offset.dy;
    double xMid = constraints.maxWidth / 2;
    double yMid = constraints.maxHeight / 2;

    var leftSide = x <= xMid;
    var topSide = y <= yMid;
    if (topSide) {
      return leftSide ? Alignment.topLeft : Alignment.topRight;
    } else {
      return leftSide ? Alignment.bottomLeft : Alignment.bottomRight;
    }
  }

  Offset initial(Alignment alignment) {
    /// Find the object size
    double ox = objectSize.width;
    double oy = objectSize.height;

    /// Find the total offset
    double xMax = constraints.maxWidth;
    double yMax = constraints.maxHeight;

    /// Calculate the remaining area
    double xRemaining = xMax - ox;
    double yRemaining = yMax - oy;

    if (alignment == Alignment.center && type == MovingType.anywhere) {
      return _offset(xRemaining / 2, yRemaining / 2);
    } else if (alignment == Alignment.topRight) {
      return _offset(xRemaining, 0);
    } else if (alignment == Alignment.topCenter) {
      return _offset(xRemaining / 2, 0);
    } else if (alignment == Alignment.bottomLeft) {
      return _offset(0, yRemaining);
    } else if (alignment == Alignment.bottomRight) {
      return _offset(xRemaining, yRemaining);
    } else if (alignment == Alignment.bottomCenter) {
      return _offset(xRemaining / 2, yRemaining);
    } else if (alignment == Alignment.centerRight) {
      return _offset(xRemaining, yRemaining / 2);
    } else if (alignment == Alignment.centerLeft) {
      return _offset(0, yRemaining / 2);
    } else {
      return _offset(0, 0);
    }
  }

  Offset update(Offset offset, Offset delta) {
    /// Find the object size
    double ox = objectSize.width;
    double oy = objectSize.height;

    /// Find the old offset
    double xTarget = offset.dx;
    double yTarget = offset.dy;

    /// Find the total offset
    double xMax = constraints.maxWidth;
    double yMax = constraints.maxHeight;

    /// Calculate the current position of the object
    xTarget = max(0, min(xTarget + delta.dx, xMax - ox));
    yTarget = max(0, min(yTarget + delta.dy, yMax - oy));

    /// Fixed offset mode not customizable
    return Offset(xTarget, yTarget);
  }

  Offset finalization(Offset offset) {
    /// Find the object size
    double ox = objectSize.width;
    double oy = objectSize.height;

    /// Find the old offset
    double xTarget = offset.dx;
    double yTarget = offset.dy;

    /// Find the total offset
    double xMax = constraints.maxWidth;
    double yMax = constraints.maxHeight;

    /// Center Side
    if (type == MovingType.centerSide) {
      /// Calculate the center of the object
      double xCenter = xTarget + ox / 2;
      double yCenter = yTarget + oy / 2;

      /// Calculate the distances from each side
      double leftDistance = xCenter;
      double rightDistance = xMax - xCenter;
      double topDistance = yCenter;
      double bottomDistance = yMax - yCenter;

      /// Find the nearest side
      double minDistance = min(
        leftDistance,
        min(rightDistance, min(topDistance, bottomDistance)),
      );

      if (minDistance == leftDistance) {
        xTarget = 0;
        yTarget = (yMax - oy) / 2;
      } else if (minDistance == rightDistance) {
        xTarget = xMax - ox;
        yTarget = (yMax - oy) / 2;
      } else if (minDistance == topDistance) {
        xTarget = (xMax - ox) / 2;
        yTarget = 0;
      } else if (minDistance == bottomDistance) {
        xTarget = (xMax - ox) / 2;
        yTarget = yMax - oy;
      }
    }

    /// Corner Side
    else if (type == MovingType.cornerSide) {
      /// Calculate the center of the object
      double xCenter = xTarget + ox / 2;
      double yCenter = yTarget + oy / 2;

      /// Calculate the mid of the area
      double xMid = xMax / 2;
      double yMid = yMax / 2;

      /// Find the nearest corner
      if (xCenter <= xMid) {
        xTarget = 0;
      } else {
        xTarget = xMax - ox;
      }

      if (yCenter <= yMid) {
        yTarget = 0;
      } else {
        yTarget = yMax - oy;
      }
    }

    /// Dock X
    else if (type == MovingType.dockX) {
      /// Calculate the center of the object
      double xCenter = xTarget + (ox / 2);

      /// Calculate the distances from each side
      double leftDistance = xCenter;
      double rightDistance = xMax - xCenter;

      /// Find the nearest side
      double minDistance = min(leftDistance, rightDistance);

      if (minDistance == leftDistance) {
        xTarget = 0;
      } else if (minDistance == rightDistance) {
        xTarget = xMax - ox;
      }
    }

    /// Dock Y
    else if (type == MovingType.dockY) {
      /// Calculate the center of the object
      double yCenter = yTarget + (oy / 2);

      /// Calculate the distances from each side
      double topDistance = yCenter;
      double bottomDistance = yMax - yCenter;

      /// Find the nearest side
      double minDistance = min(topDistance, bottomDistance);

      if (minDistance == topDistance) {
        yTarget = 0;
      } else if (minDistance == bottomDistance) {
        yTarget = yMax - oy;
      }
    }

    /// Nearest Side
    else if (type == MovingType.nearestSide) {
      /// Calculate the center of the object
      double xCenter = xTarget + (ox / 2);
      double yCenter = yTarget + (oy / 2);

      /// Calculate the distances from each side
      double leftDistance = xCenter;
      double rightDistance = xMax - xCenter;
      double topDistance = yCenter;
      double bottomDistance = yMax - yCenter;

      /// Find the nearest side
      double minDistance = min(
        leftDistance,
        min(rightDistance, min(topDistance, bottomDistance)),
      );

      if (minDistance == leftDistance) {
        xTarget = 0;
      } else if (minDistance == rightDistance) {
        xTarget = xMax - ox;
      } else if (minDistance == topDistance) {
        yTarget = 0;
      } else if (minDistance == bottomDistance) {
        yTarget = yMax - oy;
      }
    }

    /// Bottom-Center => Top-Anywhere
    else if (type == MovingType.bottomCenterTopAnywhere) {
      /// Calculate the center of the object
      double yCenter = yTarget + (oy / 2);

      /// Calculate the distances from each side
      double topDistance = yCenter;
      double bottomDistance = yMax - yCenter;

      /// Find the nearest side
      double minDistance = min(topDistance, bottomDistance);

      if (minDistance == topDistance) {
        yTarget = 0;
      } else if (minDistance == bottomDistance) {
        xTarget = (xMax - ox) / 2;
        yTarget = yMax - oy;
      }
    }

    /// Bottom-Center => Top-Corner
    else if (type == MovingType.bottomCenterTopCorner) {
      /// Calculate the center of the object
      double xCenter = xTarget + ox / 2;
      double yCenter = yTarget + oy / 2;

      /// Calculate the distances from each side
      double topDistance = yCenter;
      double bottomDistance = yMax - (yCenter + oy);

      /// Find the nearest side
      double minDistance = min(topDistance, bottomDistance);

      if (minDistance == topDistance) {
        yTarget = 0;

        /// Calculate the mid of the area
        double xMid = xMax / 2;

        /// Find the nearest corner
        if (xCenter <= xMid) {
          xTarget = 0;
        } else {
          xTarget = xMax - ox;
        }
      } else if (minDistance == bottomDistance) {
        xTarget = (xMax - ox) / 2;
        yTarget = yMax - oy;
      }
    }

    /// Top-Center => Bottom-Anywhere
    else if (type == MovingType.topCenterBottomAnywhere) {
      /// Calculate the center of the object
      double yCenter = yTarget + (oy / 2);

      /// Calculate the distances from each side
      double topDistance = yCenter;
      double bottomDistance = yMax - yCenter;

      /// Find the nearest side
      double minDistance = min(topDistance, bottomDistance);

      if (minDistance == topDistance) {
        yTarget = 0;
        xTarget = (xMax - ox) / 2;
      } else if (minDistance == bottomDistance) {
        yTarget = yMax - oy;
      }
    }

    /// Top-Center => Bottom-Corner
    else if (type == MovingType.topCenterBottomCorner) {
      /// Calculate the center of the object
      double xCenter = xTarget + ox / 2;
      double yCenter = yTarget + oy / 2;

      /// Calculate the distances from each side
      double topDistance = yCenter;
      double bottomDistance = yMax - (yCenter + oy);

      /// Find the nearest side
      double minDistance = min(topDistance, bottomDistance);

      if (minDistance == topDistance) {
        yTarget = 0;
        xTarget = (xMax - ox) / 2;
      } else if (minDistance == bottomDistance) {
        /// Calculate the mid of the area
        double xMid = xMax / 2;

        /// Find the nearest corner
        if (xCenter <= xMid) {
          xTarget = 0;
        } else {
          xTarget = xMax - ox;
        }

        yTarget = yMax - oy;
      }
    }

    /// Left-Center => Right-Anywhere
    else if (type == MovingType.leftCenterRightAnywhere) {
      /// Calculate the center of the object
      double xCenter = xTarget + (ox / 2);

      /// Calculate the distances from each side
      double rightDistance = xCenter;
      double leftDistance = xMax - xCenter;

      /// Find the nearest side
      double minDistance = min(rightDistance, leftDistance);

      if (minDistance == rightDistance) {
        xTarget = 0;
        yTarget = (yMax - oy) / 2;
      } else if (minDistance == leftDistance) {
        xTarget = xMax - ox;
      }
    }

    /// Left-Center => Right-Corner
    else if (type == MovingType.leftCenterRightCorner) {
      /// Calculate the center of the object
      double xCenter = xTarget + ox / 2;
      double yCenter = yTarget + oy / 2;

      /// Calculate the distances from each side
      double rightDistance = xCenter;
      double leftDistance = xMax - (xCenter + ox);

      /// Find the nearest side
      double minDistance = min(rightDistance, leftDistance);

      if (minDistance == rightDistance) {
        xTarget = 0;
        yTarget = (yMax - oy) / 2;
      } else if (minDistance == leftDistance) {
        xTarget = xMax - ox;

        /// Calculate the mid of the area
        double yMid = yMax / 2;

        if (yCenter <= yMid) {
          yTarget = 0;
        } else {
          yTarget = yMax - oy;
        }
      }
    }

    /// Right-Center => Left-Anywhere
    else if (type == MovingType.rightCenterLeftAnywhere) {
      /// Calculate the center of the object
      double xCenter = xTarget + (ox / 2);

      /// Calculate the distances from each side
      double rightDistance = xCenter;
      double leftDistance = xMax - xCenter;

      /// Find the nearest side
      double minDistance = min(rightDistance, leftDistance);

      if (minDistance == rightDistance) {
        xTarget = 0;
      } else if (minDistance == leftDistance) {
        xTarget = xMax - ox;
        yTarget = (yMax - oy) / 2;
      }
    }

    /// Right-Center => Left-Corner
    else if (type == MovingType.rightCenterLeftCorner) {
      /// Calculate the center of the object
      double xCenter = xTarget + ox / 2;
      double yCenter = yTarget + oy / 2;

      /// Calculate the distances from each side
      double rightDistance = xCenter;
      double leftDistance = xMax - (xCenter + ox);

      /// Find the nearest side
      double minDistance = min(rightDistance, leftDistance);

      if (minDistance == rightDistance) {
        xTarget = 0;

        /// Calculate the mid of the area
        double yMid = yMax / 2;

        /// Find the nearest corner
        if (yCenter <= yMid) {
          yTarget = 0;
        } else {
          yTarget = yMax - oy;
        }
      } else if (minDistance == leftDistance) {
        xTarget = xMax - ox;
        yTarget = (yMax - oy) / 2;
      }
    }

    /// None
    else {
      return offset;
    }

    return _offset(xTarget, yTarget);
  }

  Offset _offset(double x, double y) {
    final cx = constraints.maxWidth - objectSize.width;
    final cy = constraints.maxHeight - objectSize.height;

    return Offset(
      x == 0
          ? x + margin.left
          : x == cx
              ? x - margin.right
              : x,
      y == 0
          ? y + margin.top
          : y == cy
              ? y - margin.bottom
              : y,
    );
  }
}

enum MovingType {
  anywhere,
  dockX,
  dockY,
  centerSide,
  cornerSide,
  nearestSide,
  bottomCenterTopAnywhere,
  bottomCenterTopCorner,
  topCenterBottomAnywhere,
  topCenterBottomCorner,
  leftCenterRightAnywhere,
  leftCenterRightCorner,
  rightCenterLeftAnywhere,
  rightCenterLeftCorner;
}
