﻿
#Область КомандыФормы

&НаКлиенте
Асинх Процедура ПутьНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	Диалог = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	ВыбранныеФайлы = Ждать Диалог.ВыбратьАсинх();
	Если ВыбранныеФайлы <> Неопределено И ВыбранныеФайлы.Количество() > 0 Тогда
		Путь = ВыбранныеФайлы[0];
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Асинх Процедура ПрочитатьФайлВТЗ(Команда)
	
	ФайлНаДиске = Новый Файл(Путь);
	Результат = Ждать ФайлНаДиске.СуществуетАсинх();
	Если НЕ Результат Тогда
		Возврат;
	КонецЕсли;
	
	ФайлыДляСервера = Новый Массив();
	ФайлыДляСервера.Добавить(Новый ОписаниеПередаваемогоФайла(Путь));
	ПомещенныеФайлы = Ждать ПоместитьФайлыНаСерверАсинх( , , ФайлыДляСервера, УникальныйИдентификатор);
	
	Если ПомещенныеФайлы <> Неопределено
		И ПомещенныеФайлы.Количество() > 0
		И НЕ ПомещенныеФайлы[0].ПомещениеФайлаОтменено Тогда
		
		Адрес = ПомещенныеФайлы[0].Адрес;
		Расширение = ПомещенныеФайлы[0].СсылкаНаФайл.Расширение;
		ПрочитатьФайлВТЗНаСервере(Адрес, Расширение);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти


#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ВывестиДанныеФайлаВТаблицуРезультат(Знач ДанныеФайла)
	
	// Очистка.
	ТаблицаРезультат.Очистить();
	
	УдаляемыеЭлементы = Новый Массив;
	Для каждого Элемент Из Элементы.ТаблицаРезультат.ПодчиненныеЭлементы Цикл
		УдаляемыеЭлементы.Добавить(Элемент);
	КонецЦикла;
	
	Для каждого УдаляемыйЭлемент Из УдаляемыеЭлементы Цикл
		Элементы.Удалить(УдаляемыйЭлемент);
	КонецЦикла; 
	
	СуществуюшиеРеквизиты = ПолучитьРеквизиты("ТаблицаРезультат");
	УдаляемыеРеквизиты = Новый Массив;
	Для каждого Реквизит Из СуществуюшиеРеквизиты Цикл
		ПутьКРеквизиту = Реквизит.Путь + "." + Реквизит.Имя;
		УдаляемыеРеквизиты.Добавить(ПутьКРеквизиту);
	КонецЦикла;
	ИзменитьРеквизиты( , УдаляемыеРеквизиты);
	
	// Заполнение.
	НовыеРеквизиты = Новый Массив;
	Для Каждого Колонка Из ДанныеФайла.Колонки Цикл
		НовыеРеквизиты.Добавить(Новый РеквизитФормы(Колонка.Имя, Колонка.ТипЗначения, "ТаблицаРезультат"));
	КонецЦикла;
	
	ИзменитьРеквизиты(НовыеРеквизиты);
	
	ТаблицаРезультат.Загрузить(ДанныеФайла);
	
	Для каждого Колонка Из ДанныеФайла.Колонки Цикл
		НоваяКолонка = Элементы.Добавить(Колонка.Имя, Тип("ПолеФормы"), Элементы.ТаблицаРезультат);
		НоваяКолонка.Заголовок = Колонка.Имя;
		НоваяКолонка.Вид = ВидПоляФормы.ПолеВвода;
		НоваяКолонка.ПутьКДанным = "ТаблицаРезультат." + Колонка.Имя;
	КонецЦикла;

КонецПроцедуры


#Область ЧтениеДанных

&НаСервере
Процедура ПрочитатьФайлВТЗНаСервере(АдресФайлаВоВременномХранилище, Расширение)
	
	Если НЕ ЭтоАдресВременногоХранилища(АдресФайлаВоВременномХранилище) Тогда
		Возврат;
	КонецЕсли;
	
	ДвоичныеДанные = ПолучитьИзВременногоХранилища(АдресФайлаВоВременномХранилище);
	
	Каталог = ПолучитьИмяВременногоФайла("") + ПолучитьРазделительПути();
	ИмяФайла = Прав(Формат(ТекущаяУниверсальнаяДатаВМиллисекундах(), "ЧГ=0"), 8); // Для возможности чтения dbf.
	ИмяВременногоФайла = Каталог + ИмяФайла + Расширение;
	
	ДвоичныеДанные.Записать(ИмяВременногоФайла);
	
	Расширение = НРег(Расширение);
	
	Если Расширение = ".dbf" Тогда
		ДанныеФайла = ПрочитатьDBF(ИмяВременногоФайла);
	ИначеЕсли Расширение = ".csv" Тогда
		ДанныеФайла = ПрочитатьФайлCSV(ИмяВременногоФайла);
	ИначеЕсли Расширение = ".xls" ИЛИ Расширение = ".xlsx" Тогда
		ДанныеФайла = ПрочитатьФайлExcelЧерезТабличныйДокумент(ИмяВременногоФайла);
		//ДанныеФайла = ПрочитатьФайлExcelЧерезCOMОбъект(ИмяВременногоФайла);
	ИначеЕсли Расширение = ".json" Тогда
		ДанныеФайла = ПрочитатьФайлJson(ИмяВременногоФайла);
	Иначе
		ДанныеФайла = Новый ТаблицаЗначений;
	КонецЕсли;
	
	УдалитьФайлы(Каталог);
	
	ВывестиДанныеФайлаВТаблицуРезультат(ДанныеФайла);
	
КонецПроцедуры

&НаСервере
Функция ПрочитатьDBF(Знач ИмяВременногоФайла)
	
	ДанныеФайла = Новый ТаблицаЗначений;
	
	ДБФ = Новый XBase;
	ДБФ.Кодировка = КодировкаXBase.OEM;
	ДБФ.ОткрытьФайл(ИмяВременногоФайла, , Истина);
	
	Если НЕ ДБФ.Открыта() Тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Не удалось открыть файл " + ИмяВременногоФайла + ".";
		Сообщение.Сообщить();
		Возврат ДанныеФайла;
	КонецЕсли;
	
	// Добавление колонок в таблицу значений.
	Если ДБФ.Первая() Тогда
		
		Для каждого Поле Из ДБФ.Поля Цикл
			
			Если Поле.Тип = "S" Тогда
				// Строка.
				ТипКолонки = Новый ОписаниеТипов("Строка", ,Новый КвалификаторыСтроки(Поле.Длина));
			ИначеЕсли Поле.Тип = "N" Тогда
				// Число.
				ТипКолонки = Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(Поле.Длина, Поле.Точность));
			ИначеЕсли Поле.Тип = "D" Тогда
				// Дата.
				ТипКолонки = Новый ОписаниеТипов("Дата", , , Новый КвалификаторыДаты(ЧастиДаты.ДатаВремя));
			ИначеЕсли Поле.Тип = "L" Тогда
				// Булево.
				ТипКолонки = Новый ОписаниеТипов("Булево");
			ИначеЕсли Поле.Тип = "F" Тогда
				// Число.
				ТипКолонки = Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(Поле.Длина, Поле.Точность));
			ИначеЕсли Поле.Тип = "M" Тогда
				// Мемо.
				Продолжить;
			Иначе
				Продолжить;
			КонецЕсли;
			
			Если ДанныеФайла.Колонки.Найти(Поле.Имя) = Неопределено Тогда
				Попытка
					ДанныеФайла.Колонки.Добавить(Поле.Имя, ТипКолонки, Поле.Имя);
				Исключение
					// Если имя колонки задано числом, то в тз такое имя не пройдет.
					ДанныеФайла.Колонки.Добавить("D_" + Поле.Имя, ТипКолонки, "D_" + Поле.Имя);
				КонецПопытки;
			КонецЕсли;
			
		КонецЦикла;
		
	КонецЕсли;
	
	// Заполнение таблицы значений.
	Если ДБФ.Первая() Тогда
		
		Пока Истина Цикл
			
			Если НЕ ДБФ.ЗаписьУдалена() Тогда
				
				НоваяСтрока = ДанныеФайла.Добавить();
				
				Для каждого Поле Из ДБФ.Поля Цикл
					
					ТекИндекс = ДБФ.Поля.Индекс(Поле);
					Если ТекИндекс = -1 Тогда
						Продолжить;
					КонецЕсли;
					
					Если Поле.Тип = "S" Тогда
						// Строка.
						ТекЗнач = СокрЛП(ДБФ.ПолучитьЗначениеПоля(ТекИндекс));
					ИначеЕсли Поле.Тип = "N" Тогда
						// Число.
						ТекЗнач = ДБФ.ПолучитьЗначениеПоля(ТекИндекс);
					ИначеЕсли Поле.Тип = "D" Тогда
						// Дата.
						ТекЗнач = ДБФ.ПолучитьЗначениеПоля(ТекИндекс);
						Если ТипЗнч(ТекЗнач) = Тип("Строка") Тогда
							Если ЗначениеЗаполнено(ТекЗнач) Тогда
								ТекЗнач = Дата(Число(Прав(ТекЗнач, 4)), Число(Сред(ТекЗнач, 3, 2)), Число(Лев(ТекЗнач, 2)))
							Иначе
								ТекЗнач = Дата(1,1,1);
							КонецЕсли;
						КонецЕсли;
					ИначеЕсли Поле.Тип = "L" Тогда
						// Булево.
						ТекЗнач = ДБФ.ПолучитьЗначениеПоля(ТекИндекс);
					ИначеЕсли Поле.Тип = "F" Тогда
						// Число.
						ТекЗнач = ДБФ.ПолучитьЗначениеПоля(ТекИндекс);
					ИначеЕсли Поле.Тип = "M" Тогда
						// Мемо.
						Продолжить;
					Иначе
						Продолжить;
					КонецЕсли;
					
					Попытка
						НоваяСтрока[Поле.Имя] = ТекЗнач;
					Исключение
						НоваяСтрока["D_" + Поле.Имя] = ТекЗнач;
					КонецПопытки;
					
				КонецЦикла;
			КонецЕсли;
			
			Если НЕ ДБФ.Следующая() Тогда
				Прервать;
			КонецЕсли;
			
		КонецЦикла;
		
		Если ДБФ.Открыта() Тогда
			ДБФ.ЗакрытьФайл();
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат ДанныеФайла;
	
КонецФункции

&НаСервере
Функция ПрочитатьФайлCSV(Знач ИмяВременногоФайла)
	
	// Используется БСП - подсистема БазоваяФункциональность.
	
	ДанныеФайла = Новый ТаблицаЗначений;
	
	// ПараметрыЧтения - пример настройки, которую можно передать в функцию для чтения файла csv.
	ПараметрыЧтения = Новый Структура;
	ПараметрыЧтения.Вставить("Разделитель", ";");
	ПараметрыЧтения.Вставить("НомерСтрокиШапки", 1);
	ПараметрыЧтения.Вставить("НомерПервойСтрокиДанных", 2);
	ПараметрыЧтения.Вставить("ПропускатьПустыеСтроки", Неопределено);
	ПараметрыЧтения.Вставить("СокращатьНепечатаемыеСимволы", Ложь);
	
	ТекстовыйФайл = Новый ТекстовыйДокумент;
	ТекстовыйФайл.Прочитать(ИмяВременногоФайла);
	Шапка = ТекстовыйФайл.ПолучитьСтроку(ПараметрыЧтения.НомерСтрокиШапки);
	Шапка = СтрЗаменить(Шапка, """", "");
	Если СтрЗаканчиваетсяНа(Шапка, ПараметрыЧтения.Разделитель) Тогда
		СтроковыеФункцииКлиентСервер.УдалитьПоследнийСимволВСтроке(Шапка, 1);
	КонецЕсли;
	
	КолонкиДокумента = СтроковыеФункцииКлиентСервер.РазложитьСтрокуВМассивПодстрок(
		Шапка,
		ПараметрыЧтения.Разделитель,
		ПараметрыЧтения.ПропускатьПустыеСтроки,
		ПараметрыЧтения.СокращатьНепечатаемыеСимволы);
	
	ДобавленныеКолонки = Новый Массив;
	
	Для Каждого КолонкаДокумента Из КолонкиДокумента Цикл
		ИмяКолонки = ИмяКолонкиДляТзДанные(КолонкаДокумента);
		ДобавленныеКолонки.Добавить(ИмяКолонки);
		Если ДанныеФайла.Колонки.Найти(ИмяКолонки) = Неопределено Тогда
			Попытка
				ДанныеФайла.Колонки.Добавить(ИмяКолонки, , ИмяКолонки);
			Исключение
				// Если имя колонки задано числом, то в тз такое имя не пройдет.
				ДанныеФайла.Колонки.Добавить("D_" + ИмяКолонки, , "D_" + ИмяКолонки);
			КонецПопытки;
		КонецЕсли;
	КонецЦикла;
	
	НомерПервойСтрокиДанных = ПараметрыЧтения.НомерПервойСтрокиДанных;
	Для НомерСтроки = НомерПервойСтрокиДанных По ТекстовыйФайл.КоличествоСтрок() Цикл
		
		СтрокаФайла = ТекстовыйФайл.ПолучитьСтроку(НомерСтроки);
		СтрокаФайла = СтрЗаменить(СтрокаФайла, """", "");
		
		ДанныеСтроки = СтроковыеФункцииКлиентСервер.РазложитьСтрокуВМассивПодстрок(
			СтрокаФайла,
			ПараметрыЧтения.Разделитель,
			ПараметрыЧтения.ПропускатьПустыеСтроки,
			ПараметрыЧтения.СокращатьНепечатаемыеСимволы);
		
		Если ДанныеСтроки.Количество() = 0 Тогда
			Продолжить;
		КонецЕсли;
		
		НоваяСтрока = ДанныеФайла.Добавить();
		
		Для НомерКолонки = 0 По ДобавленныеКолонки.Количество() - 1 Цикл
			
			ИмяКолонки = ДобавленныеКолонки[НомерКолонки];
			ТекущееЗначение = ДанныеСтроки[НомерКолонки];
			Попытка
				НоваяСтрока[ИмяКолонки] = ТекущееЗначение;
			Исключение
				НоваяСтрока["D_" + ИмяКолонки] = ТекущееЗначение;
			КонецПопытки;
			
		КонецЦикла;
		
	КонецЦикла;
	
	Возврат ДанныеФайла;

КонецФункции

&НаСервере
Функция ПрочитатьФайлExcelЧерезТабличныйДокумент(ИмяВременногоФайла) Экспорт
	
	ДанныеФайла = Новый ТаблицаЗначений;
	
	ЗаголовкиКолонокВПервойСтроке = Истина;
	
	// ПараметрыЗагрузки - пример настройки, которую можно передать в функцию для чтения файла excel.
	ПараметрыЗагрузки = Новый Структура;
	ПараметрыЗагрузки.Вставить("ПервыйЛист", 1);
	ПараметрыЗагрузки.Вставить("ПоследнийЛист", 1);
	ПараметрыЗагрузки.Вставить("ПерваяСтрока", 1);
	ПараметрыЗагрузки.Вставить("ПоследняяСтрока", 0);
	ПараметрыЗагрузки.Вставить("ПерваяКолонка", 1);
	ПараметрыЗагрузки.Вставить("ПоследняяКолонка", 0);
	ПараметрыЗагрузки.Вставить("ТолькоПоследнийЛист", Ложь);
	ПараметрыЗагрузки.Вставить("НомерСтрокиЗаголовков", ?(ЗаголовкиКолонокВПервойСтроке, 1, 0));
	
	ПервыйЛист = ПараметрыЗагрузки.ПервыйЛист;
	ПоследнийЛист = ПараметрыЗагрузки.ПоследнийЛист;
	ПерваяСтрока = ПараметрыЗагрузки.ПерваяСтрока;
	ПоследняяСтрока = ПараметрыЗагрузки.ПоследняяСтрока;
	ПерваяКолонка = ПараметрыЗагрузки.ПерваяКолонка;
	ПоследняяКолонка = ПараметрыЗагрузки.ПоследняяКолонка;
	НомерСтрокиЗаголовков = ПараметрыЗагрузки.НомерСтрокиЗаголовков;
	ТолькоПоследнийЛист = ПараметрыЗагрузки.ТолькоПоследнийЛист;
	
	ТипСтрока = Новый ОписаниеТипов("Строка", ,Новый КвалификаторыСтроки());
	ТипЧисло = Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(30, 10));
	ТипДата = Новый ОписаниеТипов("Дата", Новый КвалификаторыДаты(ЧастиДаты.ДатаВремя));
	ТипБулево = Новый ОписаниеТипов("Булево");
	
	Если НомерСтрокиЗаголовков > 0 И ПерваяСтрока <= НомерСтрокиЗаголовков Тогда
		ПерваяСтрока = НомерСтрокиЗаголовков + 1;
	КонецЕсли;
	
	НачСтрока = ?(ПерваяСтрока = 0, 1, ПерваяСтрока);
	КонСтрока = ?(ПоследняяСтрока = 0, 0, ПоследняяСтрока);
	НачКолонка = ?(ПерваяКолонка = 0, 1, ПерваяКолонка);
	КонКолонка = ?(ПоследняяКолонка = 0, 0, ПоследняяКолонка);
	
	ТабДок = Новый ТабличныйДокумент;
	ТабДок.Прочитать(ИмяВременногоФайла, СпособЧтенияЗначенийТабличногоДокумента.Значение);
	
	НачЛист = ?(ПервыйЛист = 0, 1, ПервыйЛист);
	КонЛист = ?(ПоследнийЛист = 0, НачЛист, ПоследнийЛист);
	
	Если ТолькоПоследнийЛист Тогда
		НачЛист = ТабДок.Области.Количество();
		КонЛист = НачЛист;
	КонецЕсли;
	
	Для СчетчикЛистов = НачЛист По КонЛист Цикл
		
		ИмяОбласти = ТабДок.Области.Получить(СчетчикЛистов-1).Имя;
		Лист = ТабДок.ПолучитьОбласть(ИмяОбласти);
		
		Если КонСтрока = 0 Тогда
			КонСтрока = Лист.ПолучитьРазмерОбластиДанныхПоВертикали();
		КонецЕсли;
		Если КонКолонка = 0 Тогда
			КонКолонка = Лист.ПолучитьРазмерОбластиДанныхПоГоризонтали();
		КонецЕсли;
		
		мКолонокЛиста = Новый Массив;
		
		// Определяемся с числом и названиями колонок.
		Для Счетчик = НачКолонка По КонКолонка Цикл
			
			ТекЗаголовок = "";
			Если НомерСтрокиЗаголовков > 0 Тогда
				ТекЗаголовок = Лист.ПолучитьОбласть
					("R" + Формат(НомерСтрокиЗаголовков, "ЧГ=0") + "C" + Формат(Счетчик, "ЧГ=0")).ТекущаяОбласть.Текст;
			КонецЕсли;
			Если ТекЗаголовок = "" Тогда
				ТекЗаголовок = "Колонка" + Формат(Счетчик, "ЧГ=0");
			КонецЕсли;
			
			// Для определения типа колонки пробуем прочитать одну строку под
			// заголовком и из типа значения в этой строке определить тип.
			ТекущаяОбласть = Лист.ПолучитьОбласть
				("R" + Формат(НачСтрока, "ЧГ=0") + "C" + Формат(Счетчик, "ЧГ=0")).ТекущаяОбласть;
			
			ЗначениеЯчейки = ЗначениеЯчейкиТабличногоДокумента(ТекущаяОбласть);
			
			ТекТипКолонки = Неопределено;
			Если ТипЗнч(ЗначениеЯчейки) = Тип("Строка") Тогда
				ТекТипКолонки = ТипСтрока;
			ИначеЕсли ТипЗнч(ЗначениеЯчейки) = Тип("Число") Тогда
				ТекТипКолонки = ТипЧисло;
			ИначеЕсли ТипЗнч(ЗначениеЯчейки) = Тип("Дата") Тогда
				ТекТипКолонки = ТипДата;
			ИначеЕсли ТипЗнч(ЗначениеЯчейки) = Тип("Булево") Тогда
				ТекТипКолонки = ТипБулево;
			Иначе
				ТекТипКолонки = ТипСтрока;
			КонецЕсли;
			
			мКолонокЛиста.Добавить(ТекЗаголовок);
			Если ДанныеФайла.Колонки.Найти(ТекЗаголовок) = Неопределено Тогда
				ДанныеФайла.Колонки.Добавить(ТекЗаголовок, ТекТипКолонки);
			КонецЕсли;
		КонецЦикла;
		
		Для НомерСтроки = НачСтрока По КонСтрока Цикл
			НоваяСтрока = ДанныеФайла.Добавить();
			
			Для Счетчик = 0 По мКолонокЛиста.Количество() - 1 Цикл
				
				НомерКолонки = Счетчик + 1;
				ТекущаяОбласть = Лист.ПолучитьОбласть("R" + Формат(НомерСтроки, "ЧГ=0") + "C" + Формат(НомерКолонки, "ЧГ=0")).ТекущаяОбласть;
				ЗначениеЯчейки = ЗначениеЯчейкиТабличногоДокумента(ТекущаяОбласть);
				
				НоваяСтрока[мКолонокЛиста[Счетчик]] = ЗначениеЯчейки;
			КонецЦикла;
		КонецЦикла;
		
	КонецЦикла;
	
	Возврат ДанныеФайла;
	
КонецФункции

&НаСервере
Функция ПрочитатьФайлExcelЧерезCOMОбъект(Знач ИмяВременногоФайла) Экспорт
	
	ДанныеФайла = Новый ТаблицаЗначений;
	
	// ПараметрыЗагрузки - пример настройки, которую можно передать в функцию для чтения файла excel.
	ПараметрыЗагрузки = Новый Структура;
	ПараметрыЗагрузки.Вставить("НомерСтраницы", 1);
	ПараметрыЗагрузки.Вставить("ПерваяСтрока", 1);
	
	НомерСтраницы = ПараметрыЗагрузки.НомерСтраницы;
	ПерваяСтрока = ПараметрыЗагрузки.ПерваяСтрока;
	
	Попытка
		Excel = ПолучитьCOMОбъект(ИмяВременногоФайла);
	Исключение
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Не удалось открыть файл MS Excel.";
		Сообщение.Сообщить();
		Возврат ДанныеФайла;
	КонецПопытки;
	
	Попытка
		Sheet = Excel.WorkSheets(НомерСтраницы);
	Исключение
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Не удалось получить страницу №" + НомерСтраницы + " из файла MS Excel.";
		Сообщение.Сообщить(); 
		Попытка
			ЭксельБылОткрыт = Excel.Queries;
		Исключение
			Excel.Close();
		КонецПопытки;
		
		Возврат ДанныеФайла;
	КонецПопытки;
	
	КоличествоСтрок = Sheet.Cells(1,1).SpecialCells(11).Row;
	КоличествоКолонок = Sheet.Cells(1,1).SpecialCells(11).Column;
	
	Range = Sheet.Range(Sheet.Cells(ПерваяСтрока, 1), Sheet.Cells(КоличествоСтрок, КоличествоКолонок));
	ДанныеФайла = Range.Value.Выгрузить();
	
	Попытка
		// Проверка: если эксель был открыт до загрузки, его не нужно закрывать.
		ЭксельБылОткрыт = Excel.Queries;
	Исключение
		// Необходимо завершить процесс.
		Excel.Close();
	КонецПопытки;
	
	Возврат ДанныеФайла;

КонецФункции

&НаСервере
Функция ПрочитатьФайлJson(Знач ИмяВременногоФайла)
	
	Чтение = Новый ЧтениеJSON;
	Чтение.ОткрытьФайл(ИмяВременногоФайла);
	
	Данные = ПрочитатьJSON(Чтение, Истина);
	
	Чтение.Закрыть();
		
	ДанныеФайла = ТаблицаПоКлючамJSON(Данные);
	
	Возврат ДанныеФайла;
	
КонецФункции

&НаСервере
Функция ТаблицаПоКлючамJSON(Данные)
	
	ДанныеФайла = Новый ТаблицаЗначений;
	
	Для каждого КлючИЗначение Из Данные Цикл
		ДанныеФайла.Колонки.Добавить(КлючИЗначение.Ключ);
	КонецЦикла;
	
	НоваяСтрока = ДанныеФайла.Добавить();
	
	Для каждого КлючИЗначение Из Данные Цикл
		Если ТипЗнч(КлючИЗначение.Значение) = Тип("Соответствие") Тогда
			НоваяСтрока[КлючИЗначение.Ключ] = ТаблицаПоКлючамJSON(КлючИЗначение.Значение);
		ИначеЕсли ТипЗнч(КлючИЗначение.Значение) = Тип("Массив") Тогда
			ТекЗначение = "";
			Для каждого Элемент Из КлючИЗначение.Значение Цикл
				ТекЗначение = ТекЗначение + Строка(Элемент) + ",";
			КонецЦикла;
			НоваяСтрока[КлючИЗначение.Ключ] = ТекЗначение;
		Иначе
			НоваяСтрока[КлючИЗначение.Ключ] = КлючИЗначение.Значение;
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат ДанныеФайла;
	
КонецФункции
 

#КонецОбласти


#Область ПрочиеПроцедурыИФункции

&НаСервере
Функция ИмяКолонкиДляТзДанные(Знач ИмяКолонкиВФайле)

	ИмяКолонки = ИмяКолонкиВФайле;
	
	// Имя колонки в файле - это строка, которая может содержать спецсимволы,
	// запрещенные для использования в имени колонки таблицы значений.
	// Все запрещенные символы заменяем на символ "_".
	ДлинаИмениКолонки = СтрДлина(ИмяКолонки);
	Для Счетчик = 1 По ДлинаИмениКолонки Цикл
		КодСимвола = КодСимвола(Сред(ИмяКолонки, Счетчик, 1));
		Если КодСимвола < 48
			ИЛИ (КодСимвола > 57 И КодСимвола < 65)
			ИЛИ (КодСимвола > 90 И КодСимвола < 97 И КодСимвола <> 95)
			ИЛИ (КодСимвола > 122 И КодСимвола < 1040)
			ИЛИ (КодСимвола > 1103 И КодСимвола <> 1025 И КодСимвола <> 1105) Тогда
			ИмяКолонки = СтрЗаменить(ИмяКолонки, Сред(ИмяКолонки, Счетчик, 1), "_");
		КонецЕсли;
	КонецЦикла;
	
	Возврат ИмяКолонки;

КонецФункции

&НаСервере
Функция ЗначениеЯчейкиТабличногоДокумента(Знач ТекущаяОбласть)
	
	Если ТекущаяОбласть.СодержитЗначение Тогда
		ЗначениеЯчейки = ТекущаяОбласть.Значение; // Число, Дата.
	Иначе
		ЗначениеЯчейки = СокрЛП(ТекущаяОбласть.Текст); // Строка, Булево.
		Если ЗначениеЗаполнено(ЗначениеЯчейки) Тогда
			// При чтении из файлов с расширением xlsx Булево оперделяется как строка: "ИСТИНА"/"ЛОЖЬ".
			// Ограничение: при использовании файлов с расширением xls ячейка с Булево будет пустой
			// и не будет содержать ни значение, ни текст.
			Если ВРег(ЗначениеЯчейки) = "ИСТИНА" ИЛИ ВРег(ЗначениеЯчейки) = ("ИСТИНА" + Символы.ПС)
				ИЛИ ВРег(ЗначениеЯчейки) = "TRUE" ИЛИ ВРег(ЗначениеЯчейки) = ("TRUE" + Символы.ПС) Тогда
				ЗначениеЯчейки = Истина;
			ИначеЕсли ВРег(ЗначениеЯчейки) = "ЛОЖЬ" ИЛИ ВРег(ЗначениеЯчейки) = ("ЛОЖЬ" + Символы.ПС)
				ИЛИ ВРег(ЗначениеЯчейки) = "FALSE" ИЛИ ВРег(ЗначениеЯчейки) = ("FALSE" + Символы.ПС) Тогда
				ЗначениеЯчейки = Ложь;
			Иначе
				ЗначениеЯчейки = Неопределено;
			КонецЕсли;
		Иначе
			ЗначениеЯчейки = Неопределено;
		КонецЕсли;
	КонецЕсли;
	
	Возврат ЗначениеЯчейки;

КонецФункции

#КонецОбласти


#КонецОбласти








