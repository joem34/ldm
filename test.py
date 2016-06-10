import string
s=""" Albania                                       24008              7              6,316    0.0
        Canary Islands                                24013              4              3,565    0.0
        Madeira                                       24051              1                926    0.0
        Bosnia and Herzegovina                        24070              2              1,768    0.0
        Croatia                                       24191             58             45,564    0.1
        Greece                                        24300             60             49,414    0.1
        Italy                                         24380            134            109,161    0.3
        """

ss = " ".join(map(string.strip,s.splitlines())).replace('\n', "")
print ss

import re
vars = ["Question Name", "Concept", "Question Text","Universe", "Note" ]
end = "Source"
vars_reg = [v+""":\s*(.*?)\s*""" for v in vars]
reg = "".join(vars_reg) + end
m = re.match(reg,ss)
print m.groups()