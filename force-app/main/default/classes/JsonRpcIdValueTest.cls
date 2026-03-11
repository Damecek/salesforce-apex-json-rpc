@IsTest
private class JsonRpcIdValueTest {
    @IsTest
    static void testSupportedRawIdsRoundTrip() {
        List<JsonRpcIdValue> ids = new List<JsonRpcIdValue>{
            JsonRpcIdValue.fromRaw(null),
            JsonRpcIdValue.fromRaw('abc'),
            JsonRpcIdValue.fromRaw(1),
            JsonRpcIdValue.fromRaw(1234567890123L),
            JsonRpcIdValue.fromRaw(Decimal.valueOf('1.5'))
        };

        System.assertEquals(true, ids[0].isNull());
        System.assertEquals('abc', ids[1].asString());
        System.assertEquals(1, ids[2].asInteger());
        System.assertEquals(1234567890123L, ids[3].asLong());
        System.assertEquals(Decimal.valueOf('1.5'), ids[4].asDecimal());
    }

    @IsTest
    static void testTryFromRawRejectsUnsupportedTypes() {
        System.assertEquals(null, JsonRpcIdValue.tryFromRaw(true));
        System.assertEquals(null, JsonRpcIdValue.tryFromRaw(new Map<String, Object>{ 'a' => 1 }));
        System.assertEquals(null, JsonRpcIdValue.tryFromRaw(new List<Object>{ 'x' }));
    }

    @IsTest
    static void testFromRawRejectsUnsupportedTypes() {
        try {
            JsonRpcIdValue.fromRaw(true);
            System.assert(false, 'Expected unsupported id type to throw.');
        } catch (JsonRpcException ex) {
            System.assert(ex.getMessage().contains('id must be'));
        }
    }

    @IsTest
    static void testAccessorTypeMismatchThrows() {
        JsonRpcIdValue id = JsonRpcIdValue.fromRaw('abc');

        try {
            id.asInteger();
            System.assert(false, 'Expected wrong accessor type to throw.');
        } catch (JsonRpcException ex) {
            System.assert(ex.getMessage().contains('not a Integer'));
        }
    }

    @IsTest
    static void testResponseRoundTripPreservesWrappedId() {
        JsonRpcResponse response = JsonRpcResponse.success(JsonRpcIdValue.fromRaw('rpc-1'), 'ok');

        JsonRpcResponse parsed = JsonRpcResponse.fromMap((Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(response.toMap())));

        System.assertEquals('rpc-1', parsed.id.asString());
        System.assertEquals('ok', parsed.result);
    }
}
