T_b(ws);
T_b(te_set->module);
T_b(te_set->clear);
T_b("( ");
T_b(te_select_related->result_var);
T_b(", &pG_");
T_b(te_select_related->te_classGeneratedName);
T_b("_extent );");
T_b("\n");
T_b(ws);
T_b("{");
T_b(te_lnk->te_classGeneratedName);
T_b(" * selected = ");
T_b(te_lnk->left);
T_b("->");
T_b(te_lnk->linkage);
T_b(";");
T_b("\n");
T_b(ws);
T_b("if ( ( 0 != selected ) && ( ");
T_b(te_select_related->where_clause);
T_b(" ) ) {");
T_b("\n");
T_b(ws);
T_b("  ");
T_b(te_set->module);
T_b(te_set->insert_element);
T_b("( (");
T_b(te_set->scope);
T_b(te_set->base_class);
T_b(" *) ");
T_b(te_select_related->result_var);
T_b(", selected );");
T_b("\n");
T_b(ws);
T_b("}}");
T_b("\n");
