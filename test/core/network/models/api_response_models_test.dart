import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jeeai/core/network/models/api_enums.dart';
import 'package:jeeai/core/network/models/contact_response.dart';
import 'package:jeeai/core/network/models/conversation_response.dart';
import 'package:jeeai/core/network/models/latest_message_preview.dart';
import 'package:jeeai/core/network/models/message_response.dart';
import 'package:jeeai/core/network/models/pagination_response.dart';

void main() {
  group('ContactResponse', () {
    test('parses backend contact fields, nullable values, and timestamps', () {
      final contact = ContactResponse.fromJson(_contactJson);

      expect(contact.id, '2d8c4620-18d3-4bf8-93a1-8a9cb75f0002');
      expect(contact.name, 'Maya Perera');
      expect(contact.username, 'maya.p');
      expect(contact.profileImage, isNull);
      expect(contact.createdAt, DateTime.parse('2026-11-20T10:42:00.000Z'));
      expect(contact.updatedAt, DateTime.parse('2026-11-20T10:42:00.000Z'));
    });

    test('allows the smaller nested contact shape without timestamps', () {
      final contact = ContactResponse.fromJson({
        'id': 'contact-uuid',
        'name': 'Noah Silva',
        'username': null,
        'profileImage': 'https://example.test/avatar.png',
      });

      expect(contact.createdAt, isNull);
      expect(contact.updatedAt, isNull);
      expect(contact.toJson().containsKey('createdAt'), isFalse);
    });

    test('serializes a full contact response back to backend JSON shape', () {
      final contact = ContactResponse.fromJson(_contactJson);
      final roundTrip = ContactResponse.fromJson(
        jsonDecode(jsonEncode(contact.toJson())) as Map<String, dynamic>,
      );

      expect(roundTrip.toJson(), contact.toJson());
    });
  });

  group('MessageResponse', () {
    test('parses message direction, status, and date-time fields', () {
      final message = MessageResponse.fromJson(_messageJson);

      expect(message.direction, ApiMessageDirection.outgoing);
      expect(message.status, ApiMessageStatus.sent);
      expect(message.isSentByMe, isTrue);
      expect(message.createdAt.isUtc, isTrue);
      expect(message.updatedAt, DateTime.parse('2026-11-20T10:43:00.000Z'));
    });

    test('round-trips all full-message fields', () {
      final message = MessageResponse.fromJson(_messageJson);
      final roundTrip = MessageResponse.fromJson(
        jsonDecode(jsonEncode(message.toJson())) as Map<String, dynamic>,
      );

      expect(roundTrip.toJson(), message.toJson());
    });

    test('maps unknown message enum values to safe fallbacks', () {
      final message = MessageResponse.fromJson({
        ..._messageJson,
        'direction': 'SYSTEM',
        'status': 'QUEUED',
      });

      expect(message.direction, ApiMessageDirection.unknown);
      expect(message.status, ApiMessageStatus.unknown);
      expect(message.direction.toJson(), 'UNKNOWN');
      expect(message.status.toJson(), 'UNKNOWN');
    });
  });

  group('ConversationResponse', () {
    test('parses a nested contact and compact latest-message preview', () {
      final conversation = ConversationResponse.fromJson(_conversationJson);

      expect(conversation.platform, ApiPlatform.whatsapp);
      expect(conversation.unreadCount, 2);
      expect(conversation.lastMessageAt, DateTime.parse('2026-11-20T10:42:00.000Z'));
      expect(conversation.contact.name, 'Maya Perera');
      expect(conversation.contact.createdAt, isNull);
      expect(conversation.latestMessage, isA<LatestMessagePreview>());
      expect(conversation.latestMessage?.content, 'Are we still meeting tomorrow?');
      expect(conversation.latestMessage?.status, ApiMessageStatus.delivered);
    });

    test('supports null activity time and no latest message', () {
      final conversation = ConversationResponse.fromJson({
        ..._conversationJson,
        'platform': 'INSTAGRAM',
        'lastMessageAt': null,
        'latestMessage': null,
      });

      expect(conversation.platform, ApiPlatform.instagram);
      expect(conversation.lastMessageAt, isNull);
      expect(conversation.latestMessage, isNull);
    });

    test('maps an unknown platform safely and round-trips conversation JSON', () {
      final conversation = ConversationResponse.fromJson({
        ..._conversationJson,
        'platform': 'TELEGRAM',
      });
      final roundTrip = ConversationResponse.fromJson(
        jsonDecode(jsonEncode(conversation.toJson())) as Map<String, dynamic>,
      );

      expect(conversation.platform, ApiPlatform.unknown);
      expect(roundTrip.toJson(), conversation.toJson());
      expect(roundTrip.toJson()['platform'], 'UNKNOWN');
    });
  });

  group('PaginatedResponse', () {
    test('parses the shared data and pagination envelope', () {
      final response = PaginatedResponse<ContactResponse>.fromJson(
        {
          'data': [_contactJson],
          'pagination': {
            'page': 2,
            'limit': 20,
            'total': 21,
            'totalPages': 2,
          },
        },
        itemFromJson: ContactResponse.fromJson,
      );

      expect(response.data.single.name, 'Maya Perera');
      expect(response.pagination.page, 2);
      expect(response.pagination.limit, 20);
      expect(response.pagination.total, 21);
      expect(response.pagination.totalPages, 2);
      expect(
        PaginatedResponse<ContactResponse>.fromJson(
          jsonDecode(jsonEncode(response.toJson(itemToJson: (item) => item.toJson())))
              as Map<String, dynamic>,
          itemFromJson: ContactResponse.fromJson,
        ).toJson(itemToJson: (item) => item.toJson()),
        response.toJson(itemToJson: (item) => item.toJson()),
      );
    });
  });
}

const _contactJson = <String, dynamic>{
  'id': '2d8c4620-18d3-4bf8-93a1-8a9cb75f0002',
  'name': 'Maya Perera',
  'username': 'maya.p',
  'profileImage': null,
  'createdAt': '2026-11-20T10:42:00.000Z',
  'updatedAt': '2026-11-20T10:42:00.000Z',
};

const _messageJson = <String, dynamic>{
  'id': '2d8c4620-18d3-4bf8-93a1-8a9cb75f0102',
  'conversationId': '2d8c4620-18d3-4bf8-93a1-8a9cb75f0011',
  'content': 'Yes, that works for me.',
  'direction': 'OUTGOING',
  'status': 'SENT',
  'createdAt': '2026-11-20T10:42:30.000Z',
  'updatedAt': '2026-11-20T10:43:00.000Z',
};

const _conversationJson = <String, dynamic>{
  'id': '2d8c4620-18d3-4bf8-93a1-8a9cb75f0011',
  'platform': 'WHATSAPP',
  'lastMessageAt': '2026-11-20T10:42:00.000Z',
  'unreadCount': 2,
  'contact': {
    'id': '2d8c4620-18d3-4bf8-93a1-8a9cb75f0002',
    'name': 'Maya Perera',
    'username': 'maya.p',
    'profileImage': null,
  },
  'latestMessage': {
    'id': '2d8c4620-18d3-4bf8-93a1-8a9cb75f0101',
    'content': 'Are we still meeting tomorrow?',
    'direction': 'INCOMING',
    'status': 'DELIVERED',
    'createdAt': '2026-11-20T10:42:00.000Z',
  },
};
