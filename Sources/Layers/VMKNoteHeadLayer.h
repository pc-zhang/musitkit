// Copyright © 2016 Venture Media Labs.
//
// This file is part of MusicKit. The full MusicKit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

#import "VMKScoreElementImageLayer.h"
#include <mxml/geometry/NoteGeometry.h>


@interface VMKNoteHeadLayer : VMKScoreElementImageLayer

/**
 Get the image for the note head of the given type at a particlar scale.
 */
+ (NSString*)headImageNameForNote:(const mxml::dom::Note&)note;

- (instancetype)initWithNoteGeometry:(const mxml::NoteGeometry*)noteGeom;

@property(nonatomic) const mxml::NoteGeometry* noteGeometry;

@end
