SuperStrict

Framework brl.standardio
Import brl.jconv
Import BRL.MaxUnit

New TTestSuite.run()

Type TJConvTest Extends TTest

	Field jconv:TJConv
	
	Method setup() { before }
		jconv = New TJConvBuilder.WithEmptyArrays().Build()
	End Method

End Type

Type TArrayTest Extends TJConvTest

	Const EMPTY_ARRAY:String = "[]"
	Const EMPTY_OBJECT:String = "{}"
	Const STRING_ARRAY:String = "[~qOne~q, ~qTwo~q, ~qThree~q]"
	Const INT_ARRAY:String = "[1, 2, 3, 4, 5]"
	Const JSON_TYPES:String = "{~qfByte~q: 1, ~qfShort~q: 2, ~qfInt~q: 3, ~qfUInt~q: 4, ~qfLong~q: 5, ~qfULong~q: 6, ~qfSizeT~q: 7, ~qfFloat~q: 8.0, ~qfDouble~q: 9.0, ~qfString~q: ~q10~q, ~qfObject~q: {~qx~q: 1, ~qy~q: 2, ~qz~q: 3}}"
	Const JSON_TYPES_SER:String = "{~qfByte~q: 1, ~qfShort~q: 2, ~qfInt~q: 3, ~qfUInt~q: 4, ~qfLong~q: 5, ~qfULong~q: 6, ~qfSizeT~q: 7, ~qfFloat~q: 8.0, ~qfDouble~q: 9.0, ~qfString~q: ~q10~q, ~qfObject~q: {~qz~q: 3, ~qy~q: 2, ~qx~q: 1}}"

	Method testEmptyObject() { test }
		Local obj:Object
		
		assertEquals(EMPTY_OBJECT, jconv.ToJson(obj))
	End Method

	Method testEmptyArray() { test }
		Local array:Object[]
		
		array = Object[](jconv.FromJson(EMPTY_ARRAY, array))
		
		assertEquals(0, array.length)

		assertEquals(EMPTY_ARRAY, jconv.ToJson(array))
	End Method

	Method testEmptyArrayWithoutEmpties() { test }
		Local array:Object[]
		
		array = Object[](jconv.FromJson(EMPTY_ARRAY, array))
		
		assertEquals(0, array.length)

		assertEquals(EMPTY_ARRAY, New TJConvBuilder.Build().ToJson(array))
	End Method

	Method testStringsArray() { test }
		Local array:String[1]
		
		array = String[](jconv.FromJson(STRING_ARRAY, array))
		
		assertEquals(3, array.length)
		
		assertEquals(STRING_ARRAY, jconv.ToJson(array))
	End Method

	Method testStringsName() { test }		
		Local array:String[] = String[](jconv.FromJson(STRING_ARRAY, "String[]"))
		
		assertEquals(3, array.length)
		
		assertEquals(STRING_ARRAY, jconv.ToJson(array))
	End Method

	Method testIntsArray() { test }
		Local array:Int[1]
		
		array = Int[](jconv.FromJson(INT_ARRAY, array))
		
		assertEquals(5, array.length)
		
		assertEquals(INT_ARRAY, jconv.ToJson(array))
	End Method

	Method testIntsName() { test }
		Local array:Int[] = Int[](jconv.FromJson(INT_ARRAY, "Int[]"))
		
		assertEquals(5, array.length)
		
		assertEquals(INT_ARRAY, jconv.ToJson(array))
	End Method

	Method testData() { test }
		Local stream:TStream = ReadStream("data.json")
		
		Local array:TData[] = TData[](jconv.FromJson(stream, "TData[]"))
		
		stream.Close()
		
		assertNotNull(array)
		assertEquals(5, array.length)
		assertEquals("194.75.65.15", array[4].ip_address)
		
		assertNotNull(array[1].locations)
		assertNull(array[2].locations)
		assertEquals(3, array[1].locations.length)
		assertEquals(50.4575108:Double, array[1].locations[1].lat)
	End Method
	
	Method testFieldTypes() { test }
		Local types:TTypes = New TTypes
		
		assertEquals(JSON_TYPES, jconv.ToJson(types)) 
	End Method

	Method testObjectSerializer() { test }
		jconv = New TJConvBuilder.RegisterSerializer("TEmbedded", New TEmbeddedSerializer).Build()

		Local types:TTypes = New TTypes
		assertEquals(JSON_TYPES_SER, jconv.ToJson(types)) 
	End Method
	
End Type

Type TData
	Field id:Long
	Field first_name:String
	Field last_name:String
	Field email:String
	Field gender:String
	Field ip_address:String
	Field language:String
	Field locations:TLocation[]
End Type

Type TLocation
	Field lat:Double
	Field lng:Double
End Type

Type TTypes

	Field fByte:Byte = 1
	Field fShort:Short = 2
	Field fInt:Int = 3
	Field fUInt:UInt = 4
	Field fLong:Long = 5
	Field fULong:ULong = 6
	Field fSizeT:Size_T = 7
	Field fFloat:Float = 8
	Field fDouble:Double = 9
	Field fString:String = "10"
	
	Field fObject:TEmbedded = New TEmbedded(1, 2, 3)
End Type

Type TEmbedded

	Field x:Int
	Field y:Int
	Field z:Int
	
	Method New(x:Int, y:Int, z:Int)
		Self.x = x
		Self.y = y
		Self.z = z
	End Method

End Type

Type TEmbeddedSerializer Extends TJConvSerializer

	Method Serialize:TJSON(source:Object, sourceType:String)
		Local embedded:TEmbedded = TEmbedded(source)
		
		Local json:TJSONObject = New TJSONObject.Create()
		
		json.Set("z", embedded.z)
		json.Set("y", embedded.y)
		json.Set("x", embedded.x)
		
		Return json
	End Method

End Type
