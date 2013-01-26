wtsim
=========

railway surveying simulator

:Симулятор выправки железнодорожного пути
:Краткое описание

Симулятор выправки железнодорожного пути предназначен для расчета основных параметров железнодорожной линии и нахождения оптимальных сдвижек для реализации выправки железнодорожного пути в плане.
Подробное описание

Программный пакет реализован на языке Octave/Matlab и состоит из расчётных модулей и модулей, симулирующий работу выправочно-подбивочно-рихтовочной машины, что позволяет не только производить расчёт оптимальных параметров выправки записанного пути, но и тестировать новые алгоритмы расчёта.

В пакет включены:

    * Модуль для генерации произвольного плана пути, соответствующего требованиям СТН Ц-01-95.
    * Модуль измерения стрел прогиба модуль при заданном пути [versine.m].
    * Модуль, преобразующий стрелы в кривизну [v2c.m].
    * Модуль, преобразующий кривизну в стрелы [c2v.m].
    * Модуль предварительной разбивки пути на участки и нахождения их кривизн [polysec.m].
    * Модуль, осуществляющий решение задачи квадратичного программирования (оптимизацию сдвижек) путём оптимизации радиусов кривизны при известных границах участков [quadro.m].
    * Модуль, строящий путь в декартовой системе координат по известным сдвижкам [redline.m].
    * Cимулятор работы выправочной машины при выправке в плане [plan.m].
    * Модули вывода результатов в стандартном формате WinALC: [geowrite.m], [meswrite.m] и [verwrite.m].
    * Модуль [vp.m] позволяет ознакомиться с работой программы. 

Генератор пути в плане

[waygen.m]
Построение расчётного проекта пути

"Красная линия" строится с помощью модуля redline.m. test_redline.m — простейший симулятор для проверки правильности разбиения на участки и расчёта сдвижек.
Разбиение на участки

Аппроксимация проекта кривизн ломаной при известных границах участков осуществляется модулем polysec.m.

При неизвестных границах разбиение на участки проводится с помощью модуля sectioning.m.

Оптимизация проекта по границам участков.

Оптимизация по радиусам кривизны — quadro.m.

Оптимизация сдвижек.
Расчётные модули

Генератор неровностей пути — makenoise.m.

Измеритель стрел — [versine.m] — на данный момент самое медленное место.

Преобразование пути в декартовой системе координат в кривизну — w2c.m. test_w2c.m — для тестирования.

Преобразование кривизны в стрелы — c2v.m. test_c2v.m — для тестирования.

Преобразование стрел в кривизну — v2c.m.

Преобразование стрел в наклон — v2a.m.

Преобразование углов наклона в стрелы — a2v.m. Пригодится для генерации проектных стрел для продольного профиля.

Преобразование стрел в yt — v2yt.m.

research.m — для отладки и визуализации всех этих преобразований, надо согласовать его с правилом знаков.

Интегрирование методом трапеций — int.m.

Двойное интегрирование методом трапеций — int2.m.

Нахождение положения основных узлов ВПР — fullmodel.dll.
Сглаживание

fit_to_constraints.m — реализация функции fit_to_constraints.

remove_noise.m — реализация функции remove_noise.

opticorr.m — реализация метода оптимальной коррекции из статьи про выправку в продольном профиле.
Обмен данными

Для передачи данных из симулятора в Пилот-Л используется модуль meswrite.m — он создаёт файл в формате MES.

Для создания GEO и VER файлов WinALC используются модули geowrite.m и verwrite.m.

Для обратной передачи используется output.dmp.
Выправка по WinALC

simalc.m

Проводится чтение файла settings.ini, из него получают параметры измерительной хорды. Генераторы geowrite.m и verwrite.m создают GEO и VER файлы WinALC. Затем они передаются в Пилот-Л для обработки и на выходе получается файл output.dmp, по которому, в свою очередь, simalc.m производит выправку.

REFERENCES:

   1. P. Aknin, H. Chollet. A new approach for the modelling of track geometry recording vehicles and the deconvolution of versine measurements IAVSD Conference. Pretoria. 1999
   2. M. Kamiyama, A. Furukawa, A. Yoshimura. Theory and Practice of Optimum Correction Track Waveform Using Restored Track Irregularity Waveform QR of RTRI, Vol. 40, No. 2, Jun. ’99
   3. B. Aronov, T. Asano, N. Katoh, K. Mehlhorn, T. Tokuyama. Polyline Fitting of Planar Points under Min-Sum Criteria October 29, 2004
   4. K. Madsen, H.B. Nielsen, O. Tingleff. Methods for Non-Linear Least Squares Problems 2nd edition, IMM, April 2004
   5. M. Lourakis. levmar : Levenberg-Marquardt nonlinear least squares algorithms in C/C++
   6. С.С. Бюшгенс. Дифференциальная геометрия. Москва. Издательство ЛКИ. 2008.
   7. C. Mészáros. BPMPD Home Page
   8. GAlib A C++ Library of Genetic Algorithm Components
   9. А.Я. Коган, С.В. Петуховский. Расчет оптимальных сдвигов при выправке криволинейных участков пути. Вестник ВНИИЖТ, 2002, №5
  10. А.Я. Коган, С.В. Петуховский. К вопросу о расчете положения пути в плане по стрелам несимметричной измерительной хорды. Вестник ВНИИЖТ, 2002, №1
  11. Steven van Dijc, Using Genetic Algorithms for Solving Hard Problems in GIS
  12. Raphael Linus Levien, From Spiral to Spline: Optimal Techniques in Interactive Curve Design
  13. Michael Downes. Short Math Guide for LATEX
  14. В.М. Тихомиров. Рассказы о максимумах и минимумах. Москва. Издательство МЦНМО. 2006. 
