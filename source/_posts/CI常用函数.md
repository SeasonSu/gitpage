---
title: CI常用函数
date: 2017-04-07 16:33:59
tags: "PHP"
categories: "PHP"
---
#### ` 选择数据`

$this->db->select();
允许你在SQL查询中写 SELECT 部分。
$this->db->where();
$this->db->or_where();
$this->db->where_in();
<!--more-->
允许你在SQL查询中写 WHERE部分，其余各种where语句请看手册。
$this->db->get();
运行选择查询语句并且返回结果集。可以获取一个表的全部数据。
$this->db->like();
$this->db->or_like();
$this->db->not_like();
本函数允许你生成 LIKE 子句，在做查询时非常有用，其余语法请看手册。
$this->db->order_by();
帮助你设置一个 ORDER BY 子句。
$this->db->group_by();
允许你编写查询语句中的 GROUP BY 部分:
$this->db->distinct();
为查询语句添加 "DISTINCT" 关键字:
$this->db->having();
允许你为你的查询语句编写 HAVING 部分。
$this->db->limit();
限制查询所返回的结果数量:
$this->db->select_max();
为你的查询编写一个 "SELECT MAX(field)"。
$this->db->select_min();
为你的查询编写一个 "SELECT MIN(field)" 。
$this->db->select_avg();
为你的查询编写一个 "SELECT AVG(field)" 。
$this->db->select_sum();
为你的查询编写一个 "SELECT SUM(field)" 。
$this->db->join();
允许你编写查询中的JOIN部分。
$this->db->count_all_results();
允许你获得某个特定的Active Record查询所返回的结果数量。可以使用Active Record限制函数，例如 where(), or_where(), like(), or_like() 等等。

#### `插入数据`

$this->db->insert();
生成一条基于你所提供的数据的SQL插入字符串并执行查询。你可以向函数传递 数组 或一个 对象。
$this->db->insert_batch();
一次插入多条数据，生成一条基于你所提供的数据的SQL插入字符串并执行查询。你可以向函数传递 数组 或一个 对象。
$this->db->set();
本函数使您能够设置inserts(插入)或updates(更新)值。它可以用来代替那种直接传递数组给插入和更新函数的方式。

#### `更新数据`

$this->db->update();
根据你提供的数据生成并执行一条update(更新)语句。你可以将一个数组或者对象传递给本函数。
$this->db->update_batch();
Generates an update string based on the data you supply, and runs the query. You can either pass an array or an object to the function. Here is an example using an array:

#### `删除数据`

$this->db->delete();
生成并执行一条DELETE(删除)语句。
$this->db->empty_table();
生成并执行一条DELETE(删除)语句。
$this->db->truncate();
生成并执行一条TRUNCATE(截断)语句。

`链式方法`

链式方法允许你以连接多个函数的方式简化你的语法。考虑一下这个范例:
$this->db->select('title')->from('mytable')->where('id', $id)->limit(10, 20);
$query = $this->db->get();
说明: 链式方法只能在PHP 5下面运行。

`查询`

$this->db->query();
要提交一个查询，用以下函数：
$this->db->query('YOUR QUERY HERE');
query() 函数以object(对象)的形式返回一个数据库结果集。 当使用 "read" 模式来运行查询时, 你可以使用“显示你的结果集”来显示查询结果; 当使用 "write" 模式来运行查询时, 将会仅根据执行的成功或失败来返回 TRUE 或 FALSE.

#### `转义查询`

$this->db->escape()这个函数将会确定数据类型，以便仅对字符串类型数据进行转义。并且，它也会自动把数据用单引号括起来，所以你不必手动添加单引号，用法如下：  $sql = "INSERT INTO table (title) VALUES(".$this->db->escape($title).")";

#### `查询辅助函数`

$this->db->insert_id()   
这个ID号是执行数据插入时的ID。  
$this->db->affected_rows()
当执行写入操作（insert,update等）的查询后，显示被影响的行数。
$this->db->count_all();
计算出指定表的总行数并返回。在第一个参数中写入被提交的表名。

#### `生成查询记录集`

result()
该方法执行成功返回一个object 数组，失败则返回一个空数组。
result_array()
该方法执行成功时将记录集作为关联数组返回。失败时返回空数组。
row()
该函数将当前请求的第一行数据作为 object 返回。

你可以传递参数(参数是行的索引)以便获得某一行的数据。比如我们要获得第 5 行的数据： $row = $query->row(4);

row_array()
功能与 row() 一样, 区别在于该函数返回的是一个数组。
除此以外, 我们还可以使用下面的方法通过游标的方式获取记录：
$row = $query->first_row()
$row = $query->last_row()
$row = $query->next_row()
$row = $query->previous_row()
默认情况下他们将返回一个 object，同时你也可以传递参数 "array" 以便使用 array 的方式获取数据 $row = $query->first_row('array')
$row = $query->last_row('array')
$row = $query->next_row('array')
$row = $query->previous_row('array')

#### `结果集辅助函数`

$query->num_rows()
该函数将会返回当前请求的行数。
$query->num_fields()
该函数返回当前请求的字段数（列数）：
$query->free_result()
该函数将会释放当前查询所占用的内存并删除其关联的资源标识。

`自动连接`

“自动连接” 功能将在每个一页面加载时被自动实例化数据库类。要启用“自动连接”，可在application/config/autoload.php中的 library 数组里添加 database：
$autoload['libraries'] = array('database');

`手动连接`

如果仅仅是一部分页面要求数据库连接，你可以在你有需要的函数里手工添加如下代码或者在你的类里手工添加以供该类使用。
$this->load->database();

`连接多数据库`

如果你需要同时连接多于一个的数据库，你可以用以下方式来实现：
$DB1 = $this->load->database('group_one', TRUE);
$DB2 = $this->load->database('group_two', TRUE);

`表数据`

$this->db->list_tables();
返回一个包含当前连接数据库中所有表名称的数组。
$this->db->table_exists();
有时，在对某个表执行操作之前，使用该函数判断指定表是否存在很有用。返回一个布尔值。

`数据库工具类`

重要提示：  初始化数据库工具类之前，你的数据库驱动必须已经运行,因为工具类依赖于此。
加载工具类： $this->load->dbutil()
一旦初始化完毕，你可以通过 $this->dbutil 对象来访问成员函数：
$this->dbutil->list_databases()
$this->dbutil->database_exists();
$this->dbutil->xml_from_result($db_result)
$this->dbutil->backup()

`数据库缓存类`

激活缓存需要三步：
1、在服务器上创建一个可写的目录以便保存缓存文件。
2、在文件 application/config/database.php 中$db['xxxx']['cachedir']设置其目录。
3、激活缓存特性，可以在文件 application/config/database.php 中设置全局选项$db['xxxx']['cache_on']='TRUE'，也可以用以本页下面的方法手动设置。
一旦被激活，每一次含有数据库查询的页面被加载时缓存就会自动发生。

当有数据库更新，我们需要删除缓存文件
$this->db->cache_delete()
删除缓存文件与特定网页。如果你需要清除缓存后，更新您的数据库
$this->db->cache_delete('/blog', 'comments');
注意，手册上写的是 $this->db->cache_delete('blog', 'comments');但根据实际测试应该在控制器名字前加斜杠'/'才能正确执行。
$this->db->cache_delete_all()
清除所有所有的缓存文件。

`数据库维护类`

注意:  欲初始化数据库维护类，请确保你的数据库驱动已经运行，因为该类依赖于数据库驱动。
使用如下方法载入数据库维护类:
$this->load->dbforge()
一旦初始化，就可以使用$this->dbforge 对象访问类中函数:
$this->dbforge->create_database('db_name')
允许你创建由第一个参数指定的数据库。
$this->dbforge->drop_database('db_name')
允许你删除由第一个参数指定的数据库。
$this->dbforge->create_table('table_name');
声明了字段和键之后，你就可以创建一个表。  
