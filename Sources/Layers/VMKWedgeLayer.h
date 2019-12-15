// Copyright © 2016 Venture Media Labs.
//
// This file is part of MusicKit. The full MusicKit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

#import "VMKScoreElementLayer.h"
#include <mxml/geometry/SpanDirectionGeometry.h>


@interface VMKWedgeLayer : VMKScoreElementLayer

- (instancetype)initWithSpanDirectionGeometry:(const mxml::SpanDirectionGeometry*)geometry;

@property(nonatomic) const mxml::SpanDirectionGeometry* spanDirectionGeometry;

@end
