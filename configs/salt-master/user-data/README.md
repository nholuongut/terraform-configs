## $$ ?!

Terraform, or likely golang, uses $ in its templating language, which is not very considerate of other scripting languages like bash.

If you need to use bash variables, you will need to escape them by using double dollar signs ($$).
