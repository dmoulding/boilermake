#include <cat.hh>
#include <chihuahua.hh>
#include <mouse.hh>

int main (int argc, char * argv [])
{
    Cat lili("Lili");
    Dog rolf("Rolf");
    Chihuahua gidget("Gidget");
    Mouse mickey("Mickey");

    lili.talk();
    rolf.talk();
    gidget.talk();
    mickey.talk();

    return 0;
}
