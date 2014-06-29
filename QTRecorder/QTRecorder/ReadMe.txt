
QTRecorder
_________________________

v1.3

QTRecorder demonstrates QTKit audio and video media capture functionality introduced in QuickTime 7.2. QTRecorder provides audiovisual preview of both live and pre-recorded media with the ability to record the streams to disk. Also demonstrated is hot-pluggable discovery of available devices by providing a dynamic selection of capture source for both audio and video. For pre-recorded source, such as tape playback, QTRecorder provides device transport control.

Getting Started

Before you get started with QTRecorder, be sure that you are running Mac OS X v10.6 and have the following items installed on your system:

* Xcode 4 or later

* Optionally a video capture device. Devices include built-in and external iSights cameras. Also supported are compliant IIDC, USB, DV and HDV cameras. HDV support is provided by the HDV codec installed with Final Cut Pro.


Version History

8/21/11 Revision 1.3
Update for Xcode 4

12/07/09 Revision 1.2:
Updated the shouldChangeOutputFile delegate call to return NO, since it does not change the file. Fixed build warnings due to use of deprecated APIs.

03/16/07 Revision 1.1: 
This revision demonstrates modifications made to device selection. Also included in this revision is additional logic demonstrating audio preview and audio level metering. QTKit classes provide support for controlling FireWire AVC devices. This functionality enables your applications to integrate the ability to determine device recording and playback modes as well as both control and monitor tape speed and direction. QTRecorder provides a tape control user interface that is enabled synchronously with a selected FireWire AVC device such as a compliant DV camera. This revision now also provides an example of how to handle input format change notifications and retrieve media format summaries. Additionally shown is the ability to intercept video frames being rendered to a preview output and, optionally, using this to pass video through some fun CoreImage filter pipelines. QTKit has removed the need to post-process a movie at the end of a recording session and subsequently flatten the movie. Replacing this are a collection capture output notifications which mark the stages of a capture session.